classdef Driver < handle
	
	properties
		
	end
	
	methods
		
		function this = Driver()
			
			
		end
		
		function delta = SteeringAngle(this, t, x)
			delta = 1 * pi/180;
		end
		
		function F_H = DrivingForce(this, t, x)
			F_H = 0;
		end
		
	end
	
end

