<shader id="haxor/internal/Gizmo">	
	<vertex precision="medium">
	
	#define GIZMO_POINT     0
	#define GIZMO_LINE      1
	#define GIZMO_TRANSFORM 2
	#define GIZMO_BOX       3
	#define GIZMO_SPHERE    4
	#define GIZMO_ICON      5
	
	uniform mat4  WorldMatrix;
	uniform mat4  ViewMatrix;
	uniform mat4  ViewMatrixInverse;
	uniform mat4  ProjectionMatrix;
	
	uniform float   Type;
	
	uniform vec3  Size;
	uniform vec3  Center;
	uniform float Height;
	uniform float Radius;
	uniform vec3  P0;
	uniform vec3  P1;
		
	attribute vec3 vertex;
	attribute vec4 color;
	attribute vec3 uv0;
	
	varying vec4 v_color;
	varying vec3 v_uv0;
	
	void main(void) 
	{		
		vec4 p = vec4(vertex,1.0);
		
		gl_Position = vec4(0);
		
		v_color = color;
		v_uv0   = uv0;
		
		if(int(Type) == GIZMO_POINT)
		{
			gl_PointSize = Radius;
			p.xyz += Center;
			gl_Position = (p * WorldMatrix) * ViewMatrix * ProjectionMatrix;
		}
		
		if(int(Type) == GIZMO_LINE)
		{
			p.xyz = P0 + (P1 - P0) * p.x;
			gl_Position = (p * WorldMatrix) * ViewMatrix * ProjectionMatrix;
		}
		
		if(int(Type) == GIZMO_TRANSFORM)
		{
			mat4 wm    = WorldMatrix;
			
			float sx   = length(vec3(wm[0][0],wm[1][0],wm[2][0]));
			float sy   = length(vec3(wm[0][1],wm[1][1],wm[2][1]));
			float sz   = length(vec3(wm[0][2],wm[1][2],wm[2][2]));
			
			vec3 scale = vec3(sx,sy,sz);
			vec4 proj  = (vec4(0,0,0,1) * WorldMatrix) * ViewMatrix * ProjectionMatrix;
			p.xyz *= (Size / scale) * proj.w;
			gl_Position = (p * WorldMatrix) * ViewMatrix * ProjectionMatrix;
			
		}
		
		if(int(Type) == GIZMO_ICON)
		{
			mat4 wm    = WorldMatrix;			
			float sx   = length(vec3(wm[0][0],wm[1][0],wm[2][0]));
			float sy   = length(vec3(wm[0][1],wm[1][1],wm[2][1]));
			float sz   = length(vec3(wm[0][2],wm[1][2],wm[2][2]));
			
			vec3 scale = vec3(sx,sy,sz);
			vec4 proj  = (vec4(0,0,0,1) * WorldMatrix) * ViewMatrix * ProjectionMatrix;
			p.xyz *= (Size / scale) * proj.w;
			p.xyz *= mat3(ViewMatrixInverse);
			gl_Position = (p * WorldMatrix) * ViewMatrix * ProjectionMatrix;
			
		}
		
		if(int(Type) == GIZMO_BOX)
		{
			//p.x *= Size.x;		p.y *= Size.y;		p.z *= Size.z;
			p.xyz *= Size;
			p.xyz += Center;
			gl_Position = (p * WorldMatrix) * ViewMatrix * ProjectionMatrix;
			
		}
		
		if(int(Type) == GIZMO_SPHERE)
		{
			p.xyz *= Radius;
			p.xyz += Center;
			gl_Position = (p * WorldMatrix) * ViewMatrix * ProjectionMatrix;
		}
		
		
		
		
		
	}		
	</vertex>
	
	<fragment precision="medium">						
	
		uniform vec4  Tint;
		
		uniform float   Type;
		
		uniform sampler2D Texture;
		
		varying vec4 v_color;
		varying vec3 v_uv0;
		
		void main(void) 
		{			
			vec4 tex = vec4(1,1,1,1);
			
			if(int(Type) == 5)
			{
				tex = texture2D(Texture,v_uv0.xy);
			}			
			
			gl_FragColor = Tint * v_color * tex;
		}
	</fragment>	
</shader>