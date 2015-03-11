<shader id="haxor/internal/GUI">	
	<vertex precision="high">
			
	attribute vec3 vertex;
	
	uniform vec2 Screen;
	
	uniform vec2 Position;
	
	uniform vec2 Size;
	
	varying vec2 v_uv;
	
	void main(void) 
	{	
		v_uv = vec2(vertex.x,vertex.y);
		vec4 p = vec4(vertex,1.0);
		float sw = floor(Screen.x * 0.5);
		float sh = floor(Screen.y * 0.5);
		p.y  = -p.y;
		p.x *= (Size.x) / sw;
		p.y *= (Size.y) / sh;
		p.x += (Position.x) / sw;
		p.y -= (Position.y) / sh;
		p.x  = (p.x-1.0);
		p.y  = (p.y+1.0);
		p.w = 1.0;
		gl_Position = p;
		
	}		
	</vertex>
	
	<fragment precision="high">						
		
		uniform sampler2D  Texture;
		
		uniform vec4 Color;
		
		varying vec2 v_uv;
		
		void main(void) 
		{					
			gl_FragColor = texture2D(Texture,v_uv) * Color;
		}
	</fragment>	
</shader>