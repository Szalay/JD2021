classdef TrackerDriver < Driver
	
	properties
		MaximumSteeringAngle(1, 1) double {mustBePositive} = deg2rad(30);
		
		TargetDistance(1, 1) = 15;
		SafetyDistance(1, 1) = 10;
	end
	
	methods
		
		function this = TrackerDriver(track)
			this@Driver(track);
		end
		
		function delta = SteeringAngle(this, t, x)
			% x = [v_x; v_y; dpsidt; psi; x_0; y_0]
			psi = x(4);
			x_0 = x(5);
			y_0 = x(6);
			
			% Biztonsági pont
			x_A = x_0 + this.SafetyDistance * cos(psi);
			y_A = y_0 + this.SafetyDistance * sin(psi);
			
			% Eltolt pálya
			X = this.Track.X - x_A;
			Y = this.Track.Y - y_A;
			
			% Forgatás
			for i = 1:length(X)
				xy = Simulator.R(-psi) * [X(i); Y(i)];
				
				X(i) = xy(1);
				Y(i) = xy(2);
			end
			
			% Cél pont
			x_C = x_0 + this.TargetDistance * cos(psi);
			y_C = y_0 + this.TargetDistance * sin(psi);
			
			% A legközelebbi pont megkeresése
			D = Inf*ones(size(X));
			for i = 1:length(X)
				if X(i) > 0
					D(i) = sqrt((this.Track.X(i) - x_C)^2 + (this.Track.Y(i) - y_C)^2);
				end
			end
			
			[~, i_P] = min(D);
			
			delta = atan(Y(i_P) / (X(i_P) + this.SafetyDistance));
			
			delta = sign(delta) * min(abs(delta), this.MaximumSteeringAngle);
		end
		
	end
	
end

