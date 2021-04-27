classdef Simulator < handle
	
	properties
		Vehicle(1, 1) Vehicle = Vehicle();
		
		x_0 = [20; 0; 0; 0; 0; 0];
		T_S = 1e-3;
		T_0 = 25;
		
		% Eredmények
		T = [];
		U = [];
		X = [];
		Y = [];
		
	end
	
	methods
		
		function this = Simulator()
			
		end
		
		function dxdt = Model(this, t, x)
			dxdt = this.Vehicle.Model(t, x);
		end
		
		function Simulate(this)
			% Állapotegyenlet, dx/dt
			dxdt = @this.Model;
			
			% Differenciálegyenlet megoldás
			[this.T, this.X] = ode45(dxdt, 0:this.T_S:this.T_0, this.x_0);
			
			% Kimenet, y = C x + D u
			for i = 1:length(this.T)
				this.U(i, :) = [ ...
					this.Vehicle.Driver.SteeringAngle(this.T(i), this.X(i, :)'), ...
					this.Vehicle.Driver.DrivingForce(this.T(i), this.X(i, :)') ...
					];
				%this.Y(i, :)
			end
		end
		
	end
	
end

