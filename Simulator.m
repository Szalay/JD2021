classdef Simulator < handle
	
	properties
		Vehicle(:, 1) Vehicle = Vehicle.empty();
		Track(:, 1) Track = Track.empty();
		
		x_0 = [20; 0; 0; 0; 0; 0];
		T_S = 1e-3;
		T_0 = 25;
		
		% Eredmények
		T = [];
		U = [];
		X = [];
		Y = [];
		N = 0;
		
		% Megjelenítés
		F = 444;
		Window = [];
		Seeker = [];
		Button = [];
		
		IsPlayed = false;
		IsSimulated = false;
		
		TrackPlot;
		TrackPath;
		TrackTitle;
		TrackCurve;
		MovingVehicle;
		
		VehiclePlot;
		VehicleBody;
		CogVelocity;
		FrVelocity;
		RrVelocity;
	end
	
	properties (Constant)
		TrackTitleString = 'A pálya és a jármű mozgása a pályán';
	end
	
	methods
		
		function this = Simulator(vehicle, driver, track)
			this.Vehicle = vehicle;
			this.Vehicle.Driver = driver;
			
			if nargin >= 3
				this.Track = track;
			end
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
			
			this.IsSimulated = true;
			this.N = length(this.T);
		end
		
		function Plot(this)
			if ~this.IsSimulated
				disp('A megjelenítés előtt le kell futtatni a szimulációt!');
			end
			
			if ishandle(this.Window)
				delete(this.Window.Children);
			else
				while ishandle(this.F)
					this.F = this.F + 1;
				end
				
				this.Window = figure(this.F);
				this.Window.Color = [1, 1, 1];
				this.Window.Name = 'Járműszimulátor';
			end
			this.Window.SizeChangedFcn = @this.OnWindowSizeChange;
			this.Window.WindowState = 'maximized';
			
			% Animációs gomb
			this.Button = uicontrol(this.Window, 'Style', 'pushbutton');
			this.Button.String = 'Lejátszás';
			this.Button.Callback = @this.OnButtonClick;
			
			% Keresőcsúszka
			this.Seeker = uicontrol(this.Window, 'Style', 'slider');
			this.Seeker.Min = 1;
			this.Seeker.Value = 1;
			this.Seeker.Max = this.N;
			this.Seeker.Callback = @this.OnSeekerMovement;
			addlistener(this.Seeker, 'Value', 'PreSet', @this.OnSeekerMovement);
			
			drawnow;
			
			% Pálya, a jármű mozgása a pályán
			this.TrackPlot = subplot(1, 2, 1); hold on; axis equal; box on;
			this.TrackTitle = title(Simulator.TrackTitleString);
			
			% A jármű közelről
			this.VehiclePlot = subplot(1, 2, 2); hold on; axis equal; box on;
			title('A jármű közelről');
			ylim([-2, 2.5]);
			
			this.CreateGraphicElements();
			this.Refresh(1);
		end
		
		function CreateGraphicElements(this)
			this.TrackPath = plot(this.TrackPlot, ...
				this.Track.X, this.Track.Y, 'k-', 'LineWidth', 3 ...
				);
			
			this.TrackCurve = plot(this.TrackPlot, ...
				this.X(:, 5), this.X(:, 6), ...
				'Color', [0.5, 0.5, 0.5], 'LineWidth', 5);
			
			[x, y] = Simulator.DrawVehicle( ...
				this.Vehicle.l_1, this.Vehicle.l_2, this.Vehicle.b, 0, 0 ...
				);
			this.MovingVehicle = plot(this.TrackPlot, x, y, 'k-', 'LineWidth', 2);
			
			[x, y] = Simulator.DrawVehicle( ...
				this.Vehicle.l_1, this.Vehicle.l_2, this.Vehicle.b, 90*pi/180, 10*pi/180 ...
				);
			this.VehicleBody = plot(this.VehiclePlot, x, y, 'k-', 'LineWidth', 2);
			
			this.CogVelocity = plot(this.VehiclePlot, 0, 0, 'r-', 'LineWidth', 3);
			this.FrVelocity = plot(this.VehiclePlot, 0, 0, 'r-', 'LineWidth', 3);
			this.RrVelocity = plot(this.VehiclePlot, 0, 0, 'r-', 'LineWidth', 3);
		end
		
		function Refresh(this, i)
			delta = this.U(i, 1);
			psi = this.X(i, 4);
			x_S = this.X(i, 5);
			y_S = this.X(i, 6);
			
			this.TrackTitle.String = sprintf('%s (%3.3f s)', ...
				Simulator.TrackTitleString, this.T(i) ...
				);
			
			[x, y] = Simulator.DrawVehicle( ...
				this.Vehicle.l_1, this.Vehicle.l_2, this.Vehicle.b, psi, delta ...
				);
			this.MovingVehicle.XData = x + x_S;
			this.MovingVehicle.YData = y + y_S;
			
			[x, y] = Simulator.DrawVehicle( ...
				this.Vehicle.l_1, this.Vehicle.l_2, this.Vehicle.b, 90*pi/180, delta ...
				);
			this.VehicleBody.XData = x;
			this.VehicleBody.YData = y;
			
			% Sebességskála
			v_S = 1/15;
			
			% A tömegközéppont sebességvektora
			v_cog = v_S * Simulator.R(-psi + 90*pi/180) * [this.X(i, 1); this.X(i, 2)];
			this.CogVelocity.XData = [0, v_cog(1)];
			this.CogVelocity.YData = [0, v_cog(2)];
			
			% A tengelyek középpontjainak sebességvektorai
			v_fr = [v_cog(1) - v_S * this.Vehicle.l_1 * this.X(i, 3); v_cog(2)];
			this.FrVelocity.XData = [0, v_fr(1)];
			this.FrVelocity.YData = [0, v_fr(2)] + this.Vehicle.l_1;
			
			v_rr = [v_cog(1) + v_S * this.Vehicle.l_2 * this.X(i, 3); v_cog(2)];
			this.RrVelocity.XData = [0, v_rr(1)];
			this.RrVelocity.YData = [0, v_rr(2)] - this.Vehicle.l_2;
			
			drawnow;
		end
		
		function Animate(this)
			FPS = 50;
			pause on;
			N_S = round(1/this.T_S/FPS);
			
			for i = round(this.Seeker.Value):N_S:this.N
				pause(1/FPS);
				
				if ~this.IsPlayed
					return;
				end
								
				this.Refresh(i);
				
				if ~ishandle(this.Seeker)
					return;
				end
				this.Seeker.Value = i;
			end
		end
		
		function OnButtonClick(this, source, event)
			if this.IsPlayed
				this.IsPlayed = false;
				this.Button.String = 'Lejátszás';
			else
				this.IsPlayed = true;
				this.Button.String = 'Megállítás';
				this.Animate();
				
				this.IsPlayed = false;
				if ~ishandle(this.Button)
					return;
				end
				this.Button.String = 'Lejátszás';
			end
		end
		
		function OnSeekerMovement(this, source, event)
			if ~this.IsPlayed
				this.Refresh(round(this.Seeker.Value));
			end
		end
		
		function OnWindowSizeChange(this, source, event)
			m = 10;
			w = 140;
			h = 28;
			
			this.Button.Position = [m, m, w, h];
			this.Seeker.Position = [m+w+m, m, this.Window.Position(3)-(m+w+m+m), h];
		end
		
	end
	
	methods (Static)
		
		function s = Run()
			v = Vehicle.BMW3;
			%t = Track.Circle(100, 200).Shift(0, 100);
			
			t = Track( ...
				[0, 50, 100,    0, -100], ...
				[0, 25, -50, -150,  100] ...
				);
			d = TrackerDriver(t);
			
			s = Simulator(v, d, t);
			s.Simulate();
			s.Plot();
		end
		
		function [x, y] = DrawVehicle(l_1, l_2, b, psi, delta)
			r_k = 0.35;
			b_0 = b/2;
			
			XY = [ ...
				-l_2-r_k, b_0; ...
				-l_2+r_k, b_0; ...
				-l_2, b_0; ...
				-l_2, -b_0; ...
				-l_2-r_k, -b_0; ...
				-l_2+r_k, -b_0; ...
				-l_2, -b_0; ...
				-l_2, 0; ...
				l_1, 0; ...
				l_1, b_0; ...
				l_1-r_k*cos(delta), b_0-r_k*sin(delta); ...
				l_1+r_k*cos(delta), b_0+r_k*sin(delta); ...
				l_1, b_0; ...
				l_1, -b_0; ...
				l_1-r_k*cos(delta), -b_0-r_k*sin(delta); ...
				l_1+r_k*cos(delta), -b_0+r_k*sin(delta) ...
				];
			
			for i = 1:size(XY, 1)
				% Forgatás
				% x_psi = R x_0, x_psi' = (R x_0')'
				XY(i, :) = (Simulator.R(psi) * XY(i, :)')';
			end
			
			x = XY(:, 1);
			y = XY(:, 2);
		end
		
		function r = R(psi)
			r = [cos(psi), -sin(psi); sin(psi), cos(psi)];
		end
		
	end
	
end

