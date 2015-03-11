<shader id="haxor/unlit/FlatSkin">	
		<vertex precision="medium">
		
		#define SKINNING_TEXTURE_SIZE 2048.0
		#define BINDS_OFFSET		  1024.0
		
		uniform mat4  WorldMatrix;
		uniform mat4  ViewMatrix;
		uniform mat4  ProjectionMatrix;
		uniform vec3  WSCameraPosition;		
		
		uniform vec4 Tint;
		
		uniform sampler2D Skinning;
		
		attribute vec3 vertex;					
		attribute vec4 color;
		attribute vec3 normal;		
		attribute vec4 bone;
		attribute vec4 weight;
		
		
		varying vec3 v_normal;
		varying vec4 v_color;
		varying vec4 v_wsVertex;
		varying vec3 v_wsView;	
		
		vec4 SkinningRead(float id)
		{
			return texture2D(Skinning, vec2(0.0,(id/(SKINNING_TEXTURE_SIZE-1.0))));
		}
		
		mat4 SkinWorldMatrix()
		{
			
			float b;
			float o = BINDS_OFFSET;
			vec4 l0,l1,l2;
			
			b = (bone[0]) * 3.0; 			
			l0 = SkinningRead(b); l1 = SkinningRead(b+1.0); l2 = SkinningRead(b+2.0);
			mat4 j0 = mat4(l0.x,l0.y,l0.z,l0.w, l1.x,l1.y,l1.z,l1.w, l2.x,l2.y,l2.z,l2.w, 0,0,0,1);
			l0 = SkinningRead(b+o); l1 = SkinningRead(b+1.0+o); l2 = SkinningRead(b+2.0+o);
			mat4 b0 = mat4(l0.x,l0.y,l0.z,l0.w, l1.x,l1.y,l1.z,l1.w, l2.x,l2.y,l2.z,l2.w, 0,0,0,1);
			
			b = (bone[1]) * 3.0; 
			l0 = SkinningRead(b); l1 = SkinningRead(b+1.0); l2 = SkinningRead(b+2.0);
			mat4 j1 = mat4(l0.x,l0.y,l0.z,l0.w, l1.x,l1.y,l1.z,l1.w, l2.x,l2.y,l2.z,l2.w, 0,0,0,1);
			l0 = SkinningRead(b+o); l1 = SkinningRead(b+1.0+o); l2 = SkinningRead(b+2.0+o);
			mat4 b1 = mat4(l0.x,l0.y,l0.z,l0.w, l1.x,l1.y,l1.z,l1.w, l2.x,l2.y,l2.z,l2.w, 0,0,0,1);
			
			b = (bone[2]) * 3.0; 
			l0 = SkinningRead(b); l1 = SkinningRead(b+1.0); l2 = SkinningRead(b+2.0);
			mat4 j2 = mat4(l0.x,l0.y,l0.z,l0.w, l1.x,l1.y,l1.z,l1.w, l2.x,l2.y,l2.z,l2.w, 0,0,0,1);
			l0 = SkinningRead(b+o); l1 = SkinningRead(b+1.0+o); l2 = SkinningRead(b+2.0+o);
			mat4 b2 = mat4(l0.x,l0.y,l0.z,l0.w, l1.x,l1.y,l1.z,l1.w, l2.x,l2.y,l2.z,l2.w, 0,0,0,1);
			
			b = (bone[3]) * 3.0; 
			l0 = SkinningRead(b); l1 = SkinningRead(b+1.0); l2 = SkinningRead(b+2.0);
			mat4 j3 = mat4(l0.x,l0.y,l0.z,l0.w, l1.x,l1.y,l1.z,l1.w, l2.x,l2.y,l2.z,l2.w, 0,0,0,1);			
			l0 = SkinningRead(b+o); l1 = SkinningRead(b+1.0+o); l2 = SkinningRead(b+2.0+o);
			mat4 b3 = mat4(l0.x,l0.y,l0.z,l0.w, l1.x,l1.y,l1.z,l1.w, l2.x,l2.y,l2.z,l2.w, 0,0,0,1);
			
			
			return    ((b0 * j0) * weight[0])+
			          ((b1 * j1) * weight[1])+
			          ((b2 * j2) * weight[2])+
			          ((b3 * j3) * weight[3]);
			
			
		}
						
		void main(void) 
		{	
			vec4 lv = vec4(vertex,1.0);
			vec3 ln = vec3(normal);
			mat4 wm;		
			wm = (SkinWorldMatrix());			
			v_color = color * Tint;
			v_normal = ln * mat3(wm);
			vec4 hpos   = ((lv * wm) * ViewMatrix) * ProjectionMatrix;			
			gl_Position = hpos;
		}		
		</vertex>
		
		<fragment precision="medium">
						
			
			varying vec4 v_color;
			varying vec3 v_normal;
			
			
			void main(void) 
			{					
				gl_FragColor.xyz = v_color.xyz;
				gl_FragColor.a 	 = v_color.a;
			}
		</fragment>	
	</shader>