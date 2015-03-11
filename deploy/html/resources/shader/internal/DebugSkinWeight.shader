<shader id="haxor/internal/DebugSkinWeight">	
		<vertex precision="medium">
		
		#define MAX_BONES 25
		
		uniform mat4  WorldMatrix;
		uniform mat4  ViewMatrix;
		uniform mat4  ProjectionMatrix;
		uniform vec3  WSCameraPosition;		
		uniform mat4  joints[MAX_BONES];
		
		
		attribute vec3 vertex;					
		attribute vec4 color;	
		attribute vec4 bone;
		attribute vec4 weight;
		
		
		varying vec3 v_normal;
		varying vec4 v_color;
		varying vec4 v_wsVertex;
		varying vec3 v_wsView;	
		
		mat4 SkinWorldMatrix()
		{
			return    (joints[int(bone[0])] * weight[0])+
			          (joints[int(bone[1])] * weight[1])+
			          (joints[int(bone[2])] * weight[2])+
			          (joints[int(bone[3])] * weight[3]);			
		}
				
		void main(void) 
		{	
			vec4 lv = vec4(vertex,1.0);			
			mat4 wm;		
			wm = SkinWorldMatrix();	
			//wm = WorldMatrix + ((wm - WorldMatrix) * Blend);
			//wm = WorldMatrix;
			v_color = weight;			
			gl_Position = ((lv * wm) * ViewMatrix) * ProjectionMatrix;
		}		
		</vertex>
		
		<fragment precision="medium">
			
			varying vec4 v_color;
						
			void main(void) 
			{	
				gl_FragColor.xyz = v_color.xyz;
				gl_FragColor.a = 0.3;
			}
		</fragment>	
	</shader>