classdef Vehicle < handle
	
	properties
		Name(1, :) char = 'Jármű';
		Driver(1, 1) Driver = Driver();
		
		% Össztömeg [kg]
		m = 1000;
		
		% Kanyarmerevségek [N/rad]
		c_1 = 30000;
		c_2 = 25000;
		
		% Tehetetlenségi nyomaték [kg m^2]
		I_zz = 1500;
		
		% Hosszméretek [m]
		l_1 = 1.1;
		l_2 = 1.3;
		
		b = 1.5;
		
		% Légellenállás
		c_W = 0.3;
		rho_L = 1.2;
		A_0 = 2;
	end
	
	properties (Constant)
		BMW3 = Vehicle( ...
			'BMW 325i', 1250, 33000, 28000, 1750, 1.2, 1.4 ...
			);
	end
	
	properties (Dependent)
		l;
	end
	
	methods
		
		function this = Vehicle(name, m, c_1, c_2, I_zz, l_1, l_2)
			if nargin == 0
				return;
			end
			
			this.Name = name;
			
			this.m = m;
			this.c_1 = c_1;
			this.c_2 = c_2;
			this.I_zz = I_zz;
			this.l_1 = l_1;
			this.l_2 = l_2;
		end
		
		function l_0 = get.l(this)
			l_0 = this.l_1 + this.l_2;
		end
		
		function dxdt = Model(this, t, x)
			% Állapotok
			% Mindegyik a helyhez kötött koordinátarendszerben értelmezendő
			% x = [v_x; v_y; dpsidt; psi; x_0; y_0]
			v_x = x(1);
			v_y = x(2);
			dpsidt = x(3);
			psi = x(4);
			x_0 = x(5);
			y_0 = x(6);
			
			% Bemenetek
			
			% Kormányszög
			delta = this.Driver.SteeringAngle(t, x);
			
			% Hajtóerő/fékerő
			F_H = this.Driver.DrivingForce(t, x);
			
			F_Hx = F_H * cos(psi + delta);
			F_Hy = F_H * sin(psi + delta);
			M_H = F_H * this.l_1 * sin(delta);
			
			% Kúszási szögek
			[alfa_1, alfa_2] = this.SideSlipAngles(v_x, v_y, dpsidt, psi, delta);
			
			% Kerékerők
			% R(psi) = [cos(psi), -sin(psi); sin(psi), cos(psi)]
			
			% [-F_y1*sin(delta); F_y1*cos(delta)]
			F_y1 = -this.c_1 * alfa_1;
			F_y1x = -F_y1*sin(delta + psi);
			F_y1y = F_y1*cos(delta + psi);
			M_y1 = F_y1 * this.l_1 * cos(delta);
			
			% [0; F_y2]
			F_y2 = -this.c_2 * alfa_2;
			F_y2x = 0*cos(psi) - F_y2*sin(psi);
			F_y2y = 0*sin(psi) + F_y2*cos(psi);
			M_y2 = -F_y2 * this.l_2;
			
			% Légellenállás
			F_Lx = -1/2 * this.c_W * this.rho_L * this.A_0 * sign(v_x) * v_x^2;
			F_Ly = -1/2 * this.c_W * this.rho_L * this.A_0 * sign(v_y) * v_y^2;
			
			% Az állapotok deriváltjai
			dxdt = zeros(6, 1);
			
			% Az a_x0 gyorsulás
			dxdt(1) = 1/this.m * (F_Hx + F_y1x + F_y2x + F_Lx);
			
			% Az a_y0 gyorsulás
			dxdt(2) = 1/this.m * (F_Hy + F_y1y + F_y2y + F_Ly);
			
			% A legyezési szögsebesség
			dxdt(3) = 1/this.I_zz * (M_H + M_y1 + M_y2);
			
			% Nyomvonal integrálás (dead reckoning)
			dxdt(4) = dpsidt;
			dxdt(5) = v_x;
			dxdt(6) = v_y;
		end
		
		function [alfa_1, alfa_2] = SideSlipAngles(this, v_x, v_y, dpsidt, psi, delta)
			% A sebességvektor vetületei a járműhöz kötött koordináta rendszerben
			% R(-psi) [v_x; v_y]
			% R(-psi) = [cos(-psi), -sin(-psi); sin(-psi), cos(-psi)]
			v_xJ = cos(-psi) * v_x - sin(-psi) * v_y;
			v_yJ = sin(-psi) * v_x + cos(-psi) * v_y;
			
			% Kúszási szögek
			alfa_1 = atan2(v_yJ + dpsidt*this.l_1, v_xJ) - delta;
			alfa_2 = atan2(v_yJ - dpsidt*this.l_2, v_xJ);
		end
		
	end
	
end

