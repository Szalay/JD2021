classdef Track < handle
	%TRACK nyomvonal
	
	properties
		X = [];
		Y = [];
	end
	
	methods
		
		function this = Track(x, y)
			if nargin < 2
				return;
			end
			
			this.X = x;
			this.Y = y;
		end
		
		function this = Shift(this, x, y)
			this.X = this.X + x;
			this.Y = this.Y + y;
		end
		
		function Plot(this)
			figure(780);
			hold on;
			axis equal;
			plot(this.X, this.Y, 'k-', 'LineWidth', 3); 
		end
		
	end
	
	methods (Static)
		
		function t = Arc(x_0, y_0, r, n, alpha, beta)
			% Szögfelosztás
			theta = pi/180 * (alpha:((beta-alpha)/(n-1)):beta)';
			
			% Körív az [x_0; y_0] pont körül
			x = r*cos(theta) + x_0;
			y = r*sin(theta) + y_0;
			
			t = Track(x, y);
		end
		
		function t = Circle(r, n)
			% Track.Circle(100, 200);
			t = Track.Arc(0, 0, r, n, 0, 360);
		end
		
	end
	
end

