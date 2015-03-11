<shader id="haxor/internal/Error">	
		<vertex precision="medium">		
		
		uniform mat4 WorldMatrix;
		uniform mat4 ViewMatrix;
		uniform mat4 ProjectionMatrix;
		attribute vec3 vertex;
		attribute vec3 normal;
		varying vec3 onormal;
		void main(void) 
		{ 
			gl_Position = ((vec4(vertex, 1.0) * WorldMatrix) * ViewMatrix) * ProjectionMatrix; 
			onormal = normal * mat3(WorldMatrix);
		}
		
		
		</vertex>
		
		<fragment precision="medium">
		
			varying vec3 onormal;	
		
			void main(void) 
			{	
				float diff = dot(normalize(onormal),normalize(vec3(1.0,1.0,1.0))); 
				gl_FragColor = vec4(1.0, 0.0, 1, 1.0) * clamp(diff,0.3,1.0);				
			}
			
		</fragment>	
</shader>

