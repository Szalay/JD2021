classdef Driver < handle
	
	properties
		Track(:, 1) Track = Track.empty();
	end
	
	methods
		
		function this = Driver(track)
			if nargin >= 1
				this.Track = track;
			end
		end
		
		function delta = SteeringAngle(this, t, x)
			% x = [v_x; v_y; dpsidt; psi; x_0; y_0]
			
			%delta = 10*(1+2/100*t) * pi/180 * sin(2*pi*0.5*exp(-1/10*t)*t);
			
			delta = 5 * pi/180;
		end
		
		function F_H = DrivingForce(this, t, x)
			F_H = 0;
		end
		
	end
	
end

