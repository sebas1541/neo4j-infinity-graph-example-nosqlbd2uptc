// 01_create_demo_graph.cypher
// Mini red social ampliada para la demo de Neo4j.
//
// Esquema (mismo de siempre):
//   (:Persona  {nombre, edad, ciudad})
//   (:Empresa  {nombre})
//   (:Persona)-[:AMIGO_DE   {desde}]->(:Persona)    // simétrica en la práctica
//   (:Persona)-[:TRABAJA_EN {rol}  ]->(:Empresa)
//
// Tamaño:
//   - 22 Personas en 9 ciudades
//   - 4  Empresas (ACME, Globex, Initech, Hooli)
//   - ~26 amistades, 22 contratos
//
// Las 5 personas originales (Ana, Luis, Juan, Sara, Pedro) se mantienen
// con los mismos datos para que el guion de la presentación siga sirviendo.

CREATE
  // -------- Personas: las 5 originales --------
  (ana:Persona    {nombre: 'Ana',       edad: 28, ciudad: 'Bogotá'}),
  (luis:Persona   {nombre: 'Luis',      edad: 32, ciudad: 'Medellín'}),
  (juan:Persona   {nombre: 'Juan',      edad: 25, ciudad: 'Cali'}),
  (sara:Persona   {nombre: 'Sara',      edad: 30, ciudad: 'Bogotá'}),
  (pedro:Persona  {nombre: 'Pedro',     edad: 40, ciudad: 'Barranquilla'}),

  // -------- Personas adicionales --------
  (camila:Persona     {nombre: 'Camila',     edad: 27, ciudad: 'Bogotá'}),
  (diego:Persona      {nombre: 'Diego',      edad: 35, ciudad: 'Medellín'}),
  (valentina:Persona  {nombre: 'Valentina',  edad: 29, ciudad: 'Cali'}),
  (andres:Persona     {nombre: 'Andrés',     edad: 33, ciudad: 'Bogotá'}),
  (laura:Persona      {nombre: 'Laura',      edad: 26, ciudad: 'Cartagena'}),
  (carlos:Persona     {nombre: 'Carlos',     edad: 45, ciudad: 'Medellín'}),
  (mariana:Persona    {nombre: 'Mariana',    edad: 31, ciudad: 'Bogotá'}),
  (felipe:Persona     {nombre: 'Felipe',     edad: 24, ciudad: 'Bucaramanga'}),
  (daniela:Persona    {nombre: 'Daniela',    edad: 28, ciudad: 'Pereira'}),
  (sebastian:Persona  {nombre: 'Sebastián',  edad: 36, ciudad: 'Cali'}),
  (isabella:Persona   {nombre: 'Isabella',   edad: 22, ciudad: 'Bogotá'}),
  (mateo:Persona      {nombre: 'Mateo',      edad: 38, ciudad: 'Manizales'}),
  (sofia:Persona      {nombre: 'Sofía',      edad: 30, ciudad: 'Medellín'}),
  (nicolas:Persona    {nombre: 'Nicolás',    edad: 27, ciudad: 'Santa Marta'}),
  (paula:Persona      {nombre: 'Paula',      edad: 34, ciudad: 'Barranquilla'}),
  (andrea:Persona     {nombre: 'Andrea',     edad: 29, ciudad: 'Bogotá'}),
  (ricardo:Persona    {nombre: 'Ricardo',    edad: 42, ciudad: 'Medellín'}),

  // -------- Empresas --------
  (acme:Empresa    {nombre: 'ACME'}),
  (globex:Empresa  {nombre: 'Globex'}),
  (initech:Empresa {nombre: 'Initech'}),
  (hooli:Empresa   {nombre: 'Hooli'}),

  // -------- Amistades originales --------
  (ana)-[:AMIGO_DE  {desde: 2019}]->(luis),
  (luis)-[:AMIGO_DE {desde: 2020}]->(juan),
  (ana)-[:AMIGO_DE  {desde: 2021}]->(sara),
  (sara)-[:AMIGO_DE {desde: 2018}]->(pedro),
  (juan)-[:AMIGO_DE {desde: 2022}]->(pedro),

  // -------- Cluster Bogotá --------
  (ana)-[:AMIGO_DE     {desde: 2020}]->(camila),
  (ana)-[:AMIGO_DE     {desde: 2018}]->(mariana),
  (sara)-[:AMIGO_DE    {desde: 2019}]->(camila),
  (camila)-[:AMIGO_DE  {desde: 2021}]->(andres),
  (andres)-[:AMIGO_DE  {desde: 2017}]->(mariana),
  (mariana)-[:AMIGO_DE {desde: 2022}]->(isabella),
  (isabella)-[:AMIGO_DE {desde: 2023}]->(andrea),
  (andrea)-[:AMIGO_DE  {desde: 2022}]->(ana),

  // -------- Cluster Medellín --------
  (luis)-[:AMIGO_DE    {desde: 2019}]->(diego),
  (diego)-[:AMIGO_DE   {desde: 2015}]->(carlos),
  (carlos)-[:AMIGO_DE  {desde: 2020}]->(sofia),
  (sofia)-[:AMIGO_DE   {desde: 2018}]->(ricardo),
  (ricardo)-[:AMIGO_DE {desde: 2014}]->(diego),
  (luis)-[:AMIGO_DE    {desde: 2021}]->(sofia),

  // -------- Cluster Cali --------
  (juan)-[:AMIGO_DE       {desde: 2020}]->(valentina),
  (valentina)-[:AMIGO_DE  {desde: 2019}]->(sebastian),
  (sebastian)-[:AMIGO_DE  {desde: 2021}]->(juan),

  // -------- Puentes entre ciudades --------
  (camila)-[:AMIGO_DE  {desde: 2022}]->(diego),     // Bogotá <-> Medellín
  (andres)-[:AMIGO_DE  {desde: 2021}]->(valentina), // Bogotá <-> Cali
  (laura)-[:AMIGO_DE   {desde: 2019}]->(pedro),     // Cartagena <-> Barranquilla
  (paula)-[:AMIGO_DE   {desde: 2017}]->(pedro),     // Barranquilla local
  (felipe)-[:AMIGO_DE  {desde: 2020}]->(daniela),   // Bucaramanga <-> Pereira
  (mateo)-[:AMIGO_DE   {desde: 2020}]->(sebastian), // Manizales <-> Cali
  (nicolas)-[:AMIGO_DE {desde: 2021}]->(laura),     // Santa Marta <-> Cartagena
  (felipe)-[:AMIGO_DE  {desde: 2023}]->(isabella),  // Bucaramanga <-> Bogotá
  (daniela)-[:AMIGO_DE {desde: 2022}]->(andrea),    // Pereira <-> Bogotá

  // -------- Trabajadores originales --------
  (ana)-[:TRABAJA_EN  {rol: 'Data Engineer'}]->(acme),
  (juan)-[:TRABAJA_EN {rol: 'Backend'}]->(acme),
  (luis)-[:TRABAJA_EN {rol: 'DevOps'}]->(globex),
  (sara)-[:TRABAJA_EN {rol: 'PM'}]->(globex),

  // -------- ACME (resto) --------
  (camila)-[:TRABAJA_EN  {rol: 'Frontend'}]->(acme),
  (diego)-[:TRABAJA_EN   {rol: 'Tech Lead'}]->(acme),
  (mariana)-[:TRABAJA_EN {rol: 'Data Scientist'}]->(acme),
  (felipe)-[:TRABAJA_EN  {rol: 'Backend Jr'}]->(acme),

  // -------- Globex (resto) --------
  (andres)-[:TRABAJA_EN  {rol: 'UX Designer'}]->(globex),
  (sofia)-[:TRABAJA_EN   {rol: 'QA'}]->(globex),
  (nicolas)-[:TRABAJA_EN {rol: 'DevOps'}]->(globex),

  // -------- Initech --------
  (valentina)-[:TRABAJA_EN {rol: 'Mobile'}]->(initech),
  (carlos)-[:TRABAJA_EN    {rol: 'CTO'}]->(initech),
  (isabella)-[:TRABAJA_EN  {rol: 'Intern'}]->(initech),
  (sebastian)-[:TRABAJA_EN {rol: 'Backend Senior'}]->(initech),
  (andrea)-[:TRABAJA_EN    {rol: 'Product Manager'}]->(initech),

  // -------- Hooli --------
  (laura)-[:TRABAJA_EN   {rol: 'Designer'}]->(hooli),
  (paula)-[:TRABAJA_EN   {rol: 'Marketing Lead'}]->(hooli),
  (mateo)-[:TRABAJA_EN   {rol: 'Data Analyst'}]->(hooli),
  (ricardo)-[:TRABAJA_EN {rol: 'CEO'}]->(hooli),
  (daniela)-[:TRABAJA_EN {rol: 'Recruiter'}]->(hooli),
  (pedro)-[:TRABAJA_EN   {rol: 'Operations'}]->(hooli);
