-- Seed data for testing (optional)

-- Insert sample vaccine types for reference
INSERT INTO public.vaccines (id, pet_id, name, description, application_date, next_dose_date)
SELECT 
  gen_random_uuid(),
  (SELECT id FROM public.pets LIMIT 1),
  vaccine_name,
  vaccine_desc,
  CURRENT_DATE - INTERVAL '30 days',
  CURRENT_DATE + INTERVAL '335 days'
FROM (
  VALUES 
    ('V8 ou V10', 'Vacina múltipla contra cinomose, hepatite, parainfluenza, parvovirose, etc.'),
    ('Antirrábica', 'Vacina contra raiva'),
    ('Giardíase', 'Vacina contra giardíase'),
    ('Gripe Canina', 'Vacina contra tosse dos canis'),
    ('Leishmaniose', 'Vacina contra leishmaniose visceral'),
    ('Tríplice Felina', 'Vacina contra rinotraqueíte, calicivirose e panleucopenia'),
    ('Quíntupla Felina', 'Vacina tríplice + clamidiose + leucemia felina'),
    ('Antirrábica Felina', 'Vacina contra raiva para gatos')
) AS sample_vaccines(vaccine_name, vaccine_desc)
WHERE EXISTS (SELECT 1 FROM public.pets LIMIT 1);
