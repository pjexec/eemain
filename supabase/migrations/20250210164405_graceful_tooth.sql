-- Create a test user
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  'a96d4bb7-c243-4e3f-9f2c-6e6b1b7e127d',
  'authenticated',
  'authenticated',
  'admin@expert.email',
  '$2a$10$Q.VvU6TJc1bqR1Ev6/.Bee8TF/0BSsqk8/Lqz5hUn4NRuWmjqK6Ue', -- Password: admin123
  now(),
  now(),
  now()
);

-- Add some test heatmap data
INSERT INTO public.heatmap_data (x, y, value, page, element_type, timestamp)
SELECT 
  (random() * 1000)::integer as x,
  (random() * 600)::integer as y,
  (random() * 10 + 1)::integer as value,
  '/',
  CASE (random() * 2)::integer
    WHEN 0 THEN 'button'
    WHEN 1 THEN 'link'
    ELSE 'div'
  END as element_type,
  now() - (random() * interval '24 hours') as timestamp
FROM generate_series(1, 100);