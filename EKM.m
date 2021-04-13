classdef EKM < handle
	%EKM Egykerékmodell
	
	properties (Constant)
		
		% Kezdeti értékek
		v_0 = 20;
		w_0 = EKM.v_0/EKM.R_K;
		
		% Méretek
		m = 1000;					% [kg]
		g = 9.81;					% [N/kg] = [m/s^2]
		
		% Kerék
		R_K = 0.35;					% [m]
		J_K = 1.5;					% [kg m^2]
		B_H = 1;					% [N m/(rad/s)]
		
		% Légellenállás
		c_W = 0.3;
		rho_L = 1.2;				% [kg/m^3]
		A_0 = 2;					% [m^2]
		
		% Irányítórendszer
		T_ABS = 10e-3;				% [s]
		
		% Fékrendszer ...
		p_V0 = 762;					% [kPa]
		p_V1 = 2;
		p_V2 = 1.41;
		p_V3 = 0.097;
		
		V_0 = 0.59;					% [cm^3], a haszontalan térfogat
		
		p_0 = 20000;				% [kPa] = 200 bar, a főfékhenger nyomása
		T_D = 10e-3;				% [s]
		C_q = 1.4;					% [cm^3/(s*sqrt(kPa))
		
		A_F = 4e-4;					% [m^2], a fékmunkahenger keresztmetszete
		mu_F = 1;
		R_F = 0.2;					% [m], a féktárcsa közepes sugara
	end
	
	methods (Static)
		
		function mu_x = PacejkaLongitudinalForceCoefficient(s_x)
			B = 3.76;
			C = 2.7;
			D = 1;
			E = 1;
			
			% Magic formula
			mu_x = D * sin( ...
				C * atan( ...
					B * ( (1-E)*s_x + E/B * atan(B*s_x)) ...
					) ...
				);
		end
		
		function PacejkaTest()
			s_x = -1:0.025:1;
			
			figure(150); hold on;
			title('Pacejka, \mu_x(s_x)');
			
			plot(s_x, EKM.PacejkaLongitudinalForceCoefficient(s_x), 'LineWidth', 3);
		end
		
		function m_f = M_F(w, M, M_F0)
			if w ~= 0
				% A kerék még forgásban van
				m_f = -sign(w) * M_F0;
			else
				% A kerék nem forog
				if abs(M) > M_F0
					m_f = -sign(w) * M_F0;
				else
					m_f = -M;
				end
			end
		end
		
		function p = BrakePressure(V)
			if V > EKM.V_0
				p = EKM.p_V0 * ( ...
					V - EKM.p_V1 * (1 - exp( ...
						-(V - EKM.p_V3) / EKM.p_V2 ...
						))...
					);
			else
				p = 0;
			end
		end
		
	end
	
end

