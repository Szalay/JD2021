classdef Driver < handle
	
	properties
		
	end
	
	methods
		
		function this = Driver()
			
			
		end
		
		function delta = SteeringAngle(this, t, x)
			delta = 10*(1+2/100*t) * pi/180 * sin(2*pi*0.5*exp(-1/10*t)*t);
		end
		
		function F_H = DrivingForce(this, t, x)
			F_H = 0;
		end
		
	end
	
end

