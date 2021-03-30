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
		
	end
	
end

