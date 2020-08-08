
class Particle
{
  public PVector position;
  public PVector velocity;

  public Particle(PVector _position, PVector _velocity)
  {
    position = _position;
    velocity = _velocity;
  }
}

class Emitter
{
  private Particle[] particles;
  // Settings
  public float x;
  public float y; 
  public color colorStart;
  public color colorEnd;
  public float timeAlive = 0;
  public float lifetime;
  public float sizeStart;
  public float sizeEnd;
  public float speedMin;
  public float speedMax;
  public float drag; 
  //
  private float t = 0;

  public void update()
  {
    for (Particle p : particles)
    {
      p.position.add(p.velocity);
      p.velocity.mult(1.0 - (drag * drag));
    }
    timeAlive += deltaTime; 

    t = min(1, timeAlive / lifetime);
  }

  public void draw()
  {
    float size = lerp(sizeStart, sizeEnd, t);
    float halfsize = size / 2.0;
    color c = lerpColor(colorStart, colorEnd, t);

    noStroke();
    fill(c);
    for (Particle p : particles)
    {
      rect(p.position.x - halfsize, p.position.y - halfsize, size, size);
    }
  }

  public Emitter(
    float _x, float _y, float _lifetime, int _particleCount, 
    color _colorStart, color _colorEnd, 
    float _sizeStart, float _sizeEnd, 
    float _speedMin, float _speedMax, float _drag, 
    PVector _direction, float _angleFuzz
    )
  {
    x = _x;
    y = _y;
    lifetime = _lifetime;
    colorStart = _colorStart;
    colorEnd = _colorEnd;
    sizeStart = _sizeStart;
    sizeEnd = _sizeEnd;
    speedMin = _speedMin;
    speedMax = _speedMax;
    drag = _drag;

    particles = new Particle[_particleCount];
    for (int i = 0; i < particles.length; i++)
    {
      float fuzz = random(_angleFuzz) - (_angleFuzz / 2.0);

      PVector vel = new PVector(_direction.x, _direction.y);
      vel.rotate(fuzz * (PI / 180.0));
      
      float speed = speedMin + random(speedMax - speedMin); 
      vel.mult(speed);

      particles[i] = new Particle(new PVector(_x, _y), vel);
    }
  }
}

static class EmitterController
{
  static private ArrayList<Emitter> emitters = new ArrayList<Emitter>();

  static public void add(Emitter e)
  {
    emitters.add(e);
  }

  static public void update()
  {
    ArrayList<Emitter> destroyRef = new ArrayList<Emitter>();

    for (int i = 0; i < emitters.size(); i++)
    {
      emitters.get(i).update();
      if (emitters.get(i).timeAlive > emitters.get(i).lifetime)
        destroyRef.add(emitters.get(i));
    }

    for (Emitter e : destroyRef)
    {
      emitters.remove(e);
    }
  }

  static public void draw()
  {
    for (Emitter e : emitters)
    {
      e.draw();
    }
  }
}
