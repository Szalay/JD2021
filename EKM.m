classdef EKM < handle
	%EKM Egykerékmodell
	
	properties
		
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
		
	end
	
end

