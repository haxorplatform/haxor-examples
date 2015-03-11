<shader id="haxor/unlit/Flat">	
		<vertex precision="medium">
		
		uniform mat4  WorldMatrix;
		uniform mat4  ViewMatrix;
		uniform mat4  ProjectionMatrix;
		
		uniform vec4  Tint;
				
		attribute vec3 vertex;		
		attribute vec4 color;
		
		varying vec4 v_color;
		
		void main(void) 
		{		
			gl_Position = ((vec4(vertex, 1.0) * WorldMatrix) * ViewMatrix) * ProjectionMatrix;				
			v_color = color * Tint;
		}		
		</vertex>
		
		<fragment precision="medium">
			
			varying vec4 v_color;
			
			void main(void) 
			{	
				gl_FragColor = v_color;				
			}
			
		</fragment>	
</shader>