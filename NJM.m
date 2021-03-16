classdef NJM < handle
	%NJM Negyedjárműmodell
	
	properties
		% Bemenet
		F = @(t, x) 0;
		v = @(t, x) 0;
		z = @(t, x) 0;
		
		u = @(t, x) [0; NJM.g; 0; 0];
		
		% Időzítés
		T_S = 1e-3;			% [s]
		T_0 = 1;			% [s]
		
		% Kezdeti érték vektor
		x_0 = [0; 0; 0; 0];
		
		% Megoldás tárolása
		T;
		U;
		X;
		Y;
		
		% Megjelenítés
		AnimationWindow;
		M_R;
		M_0;
		
		IsAnimationRunning = false;
	end
	
	properties (Constant)
		g = 9.81;				% [m/s^2]
		
		% Busz
		m_R = 4500;				% [kg]
		c_R = 300000;			% [N/m]
		k_R = 20000;			% [N/(m/s)]
		
		m_0 = 500;				% [kg]
		c_0 = 1600000;			% [N/m]
		k_0 = 150;				% [N/(m/s)]
		
		R_K = 0.5;
		
		% Lengéscsillapító hossza
		L_0 = 0.75;
		
		% Állapotvektor
		% x = [v_R; v_0; z_R; z_0]
		
		% Rendszermátrix
		A = [ ...
			[-NJM.k_R,  NJM.k_R,             -NJM.c_R,   NJM.c_R]/NJM.m_R; ...
			[ NJM.k_R, -(NJM.k_0 + NJM.k_R),  NJM.c_R, -(NJM.c_0 + NJM.c_R)]/NJM.m_0; ...
			1, 0, 0, 0; ...
			0, 1, 0, 0 ...
			];
		
		% Bemenet
		% u = [F; g; v; z]
		
		% Bemeneti mátrix
		B = [ ...
			 1/NJM.m_R, -1, 0, 0; ...
			-1/NJM.m_0, -1, NJM.k_0/NJM.m_0, NJM.c_0/NJM.m_0; ...
			0, 0, 0, 0; ...
			0, 0, 0, 0 ...
			];
		
		% Kimenet
		% y = [a_R] (a rugózott tömeg függőleges gyorsulása)
		
		% Kimeneti mátrix
		C = [-NJM.k_R,  NJM.k_R, -NJM.c_R, NJM.c_R]/NJM.m_R;
		
		% Előrecsatolási mátrix
		D = [1/NJM.m_R, -1, 0, 0];
	end
	
	methods
		
		function this = NJM(x_0)
			if nargin >= 1
				this.x_0 = x_0;
			end
			
			this.u = @(t, x) [ ...
				this.F(t, x); NJM.g; this.v(t, x); this.z(t, x) ...
				];
			
			% Bemenetek: 1) útfelület, 2) F
		end
		
		function Simulate(this)
			% Állapotegyenlet, dx/dt = A x + B u
			dxdt = @(t, x) NJM.A * x + NJM.B * this.u(t, x);
			
			% Differenciálegyenlet megoldás
			[this.T, this.X] = ode45(dxdt, 0:this.T_S:this.T_0, this.x_0);
			
			% Kimenet, y = C x + D u
			for i = 1:length(this.T)
				this.U(i, :) = this.u(this.T(i), this.X(i, :)');
				this.Y(i, :) = NJM.C * this.X(i, :)' + NJM.D * this.U(i, :)';
			end
		end
		
		function Plot(this)
			figure(456); 
			
			% Bemenetek
			% u = [F; g; v; z]
			
			subplot(3, 2, 1); hold on;
			title('Az útfelület magassága');
			plot(this.T, this.U(:, 4), 'LineWidth', 2);
			
			subplot(3, 2, 2); hold on;
			title('Az útfelület sebessége');
			plot(this.T, this.U(:, 3), 'LineWidth', 2);
			
			% Állapotok
			% x = [v_R; v_0; z_R; z_0]
			
			subplot(3, 2, 3); hold on;
			title('Sebességek');
			plot(this.T, this.X(:, [1, 2]), 'LineWidth', 2);
			
			subplot(3, 2, 4); hold on;
			title('Elmozdulások');
			plot(this.T, this.X(:, [3, 4]), 'LineWidth', 2);
			
			% Kimenet
			subplot(3, 2, [5, 6]); hold on;
			title('Kimenet (függőleges gyorsulás)');
			plot(this.T, this.Y, 'LineWidth', 2);
		end
		
		function Animate(this)
			this.AnimationWindow = figure(457);
			delete(this.AnimationWindow.Children);
			this.AnimationWindow.Name = 'Negyedjárműmodell';
			
			hold on;
			axis equal;
			set(gca, 'YLim', [-0.2, 1.6]);
			title('Negyedjármű modell');
			
			% Útfelület
			plot([-1, 1], [0, 0], 'k-', 'LineWidth', 3);
			
			[x_T, y_T] = NJM.Rectangle(0, NJM.R_K + NJM.L_0, 1, 0.5);
			this.M_R = plot(x_T, y_T, 'b-', 'LineWidth', 3);
			
			[x_K, y_K] = NJM.Circle(0, NJM.R_K, NJM.R_K);
			this.M_0 = plot(x_K, y_K, 'k-', 'LineWidth', 3);
			
			% Menü
			m = uimenu(this.AnimationWindow, 'Text', 'Negyedjárműmodell');
			uimenu(m, 'Text', 'Animáció', 'MenuSelectedFcn', @this.OnRender);
		end
		
		function OnRender(this, ~, ~)
			if this.IsAnimationRunning
				return;
			end
			this.IsAnimationRunning = true;
			
			fps = 50;
			dt = 1/fps;	% 20 ms, T_S = 1 ms -> 20-szoros lassítás, ha N = 1
			N = 20;
			
			for i = 1:N:length(this.T)
				title(sprintf( ...
					'Negyedjármű modell, %d s', floor(this.T(i)) ...
					));
				
				% Állapotok
				% x = [v_R; v_0; z_R; z_0]
				z_R = this.X(i, 3);
				z_0 = this.X(i, 4);
				
				[x_T, y_T] = NJM.Rectangle(0, z_R + NJM.R_K + NJM.L_0, 1, 0.5);
				this.M_R.XData = x_T;
				this.M_R.YData = y_T;
				
				[x_K, y_K] = NJM.Circle(0, z_0 + NJM.R_K, NJM.R_K);
				this.M_0.XData = x_K;
				this.M_0.YData = y_K;
				
				drawnow;
			end
			
			this.IsAnimationRunning = false;
		end
		
	end
	
	methods (Static)
		
		function njm = Run()
			njm = NJM();
			
			njm.T_0 = 10;
			
			% Bukkanó
			t_A = 5;
			v_x = 30/3.6;
			
			X = 1;
			x_A = v_x * t_A;
			x_B = x_A + X;
			
			Z = 0.1;
			
			window = @(t)(x_A/v_x<=t && t <=x_B/v_x);
			
			% A sin(w t + q)
			z = @(t, x) window(t) * Z*sin(pi/X * (v_x*t - x_A));
			
			% A w cos(w t + q)
			v = @(t, x) window(t) * Z*v_x*pi/X * cos(pi/X * (v_x*t - x_A));
			
			njm.z = z;
			njm.v = v;
			
			njm.Simulate();
			njm.Plot();
		end
			
		function [x, y] = Circle(x_0, y_0, R)
			th = 0:pi/50:2*pi;
			x = R * cos(th) + x_0;
			y = R * sin(th) + y_0;
		end

		function [x, y] = Rectangle(x_0, y_0, a, b)
			x = [-a/2, a/2, a/2, -a/2, -a/2] + x_0;
			y = [-b/2, -b/2, b/2, b/2, -b/2] + y_0;
		end
		
		function [x_S, y_S] = SteadyState(u_S)
			% Állandósult bemenet
			% u = [F_S; g; 0; z_S]
			
			% Állandósult állapot
			% dx/dt = A x_S + B u_S = 0
			% A x_S = -B u_S
			% (A^-1) A x_S = (A^-1) (-B) u_S
			% x_S = (A^-1) (-B) u_S
			x_S = NJM.A \ (-NJM.B) * u_S;
			
			% Állandósult kimenet
			y_S = NJM.C * x_S + NJM.D * u_S;
		end
		
	end
	
end

