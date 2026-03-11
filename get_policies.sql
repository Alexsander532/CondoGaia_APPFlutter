SELECT polname, polcmd, qual, with_check 
FROM pg_policy 
WHERE polrelid = 'categorias_financeiras'::regclass;
