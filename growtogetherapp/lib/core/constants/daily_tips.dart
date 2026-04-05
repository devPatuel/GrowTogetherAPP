/// Consejos diarios organizados por idioma.
/// Cada idioma tiene al menos 60 consejos de categorías variadas,
/// incluyendo sostenibilidad medioambiental.
class DailyTips {
  DailyTips._();

  static const Map<String, List<String>> tips = {
    'es': _tipsEs,
    'en': _tipsEn,
    'ca': _tipsCa,
  };

  static List<String> getTips(String languageCode) {
    return tips[languageCode] ?? tips['es']!;
  }

  // ─── CASTELLANO ───────────────────────────────────────────────────

  static const _tipsEs = [
    // Salud y ejercicio (10)
    'Bebe un vaso de agua nada más levantarte. Tu cuerpo lleva horas sin hidratarse y lo necesita para arrancar.',
    'Dedica 5 minutos a estirar antes de empezar el día. Tu espalda y cuello te lo agradecerán, sobre todo si trabajas sentado.',
    'Intenta caminar al menos 20 minutos hoy. No hace falta correr: caminar ya mejora tu estado de ánimo y tu salud cardiovascular.',
    'Prueba a meditar 3 minutos con los ojos cerrados. Solo céntrate en tu respiración, sin juzgar los pensamientos que aparezcan.',
    'Duerme entre 7 y 8 horas esta noche. El descanso no es un lujo, es la base de todo lo demás.',
    'Haz 10 sentadillas ahora mismo. Romper la inactividad con un movimiento rápido activa tu cuerpo y despeja la mente.',
    'Reduce el café después de las 14h. La cafeína tarda hasta 8 horas en eliminarse y puede sabotear tu sueño.',
    'Incluye una pieza de fruta en tu próxima comida. Pequeños cambios acumulados transforman tu alimentación.',
    'Cada hora, levántate y muévete 2 minutos. Estar sentado mucho tiempo seguido ralentiza tu metabolismo.',
    'Prueba a cenar al menos 2 horas antes de dormir. Tu digestión será más fácil y dormirás mejor.',

    // Productividad (10)
    'Empieza el día por la tarea más difícil. Tu energía y concentración son máximas por la mañana.',
    'Usa la técnica Pomodoro: 25 minutos de foco y 5 de descanso. Es mejor trabajar en bloques que intentar concentrarte horas seguidas.',
    'Antes de abrir el móvil, escribe las 3 cosas más importantes de hoy. Decidir tus prioridades antes de que otros lo hagan por ti.',
    'Silencia las notificaciones mientras trabajas en algo importante. Cada interrupción cuesta unos 23 minutos de refoco.',
    'Agrupa tareas similares. Responder emails, hacer llamadas o revisar código rinden más si los haces de seguido.',
    'Planifica mañana antes de terminar hoy. Empezarás el día con dirección en vez de improvisar.',
    'Aprende a decir no. Cada sí a algo poco importante es un no a algo que de verdad te importa.',
    'Si una tarea te lleva menos de 2 minutos, hazla ahora. Acumular pequeñeces satura tu lista mental.',
    'Revisa tu progreso semanal cada viernes. Saber cuánto has avanzado te motiva más que cualquier app.',
    'Elimina una distracción de tu escritorio hoy. Un espacio limpio reduce la carga cognitiva.',

    // Bienestar mental (10)
    'Escribe 3 cosas por las que estás agradecido hoy. La gratitud cambia literalmente la química de tu cerebro.',
    'Desconéctate de las pantallas 30 minutos antes de dormir. La luz azul engaña a tu cerebro haciéndole creer que es de día.',
    'Dedica 10 minutos a escribir lo que piensas sin filtro. El journaling te ayuda a procesar emociones y encontrar claridad.',
    'Respira profundo 5 veces cuando sientas estrés. La respiración lenta activa tu sistema nervioso parasimpático.',
    'Hoy intenta no compararte con nadie en redes sociales. Lo que ves es una selección, no la realidad completa.',
    'Permítete un momento de no hacer nada. El aburrimiento es el espacio donde nacen las mejores ideas.',
    'Habla con alguien de confianza sobre cómo te sientes. Compartir no es debilidad, es inteligencia emocional.',
    'Celebra un pequeño logro de hoy, por insignificante que parezca. Reconocer el avance refuerza el hábito.',
    'Sal al aire libre al menos 10 minutos. La luz natural regula tu ritmo circadiano y mejora tu ánimo.',
    'Acepta que hoy no tienes que ser perfecto. El progreso imperfecto supera a la perfección paralizada.',

    // Sostenibilidad (15)
    'Lleva tu propia bolsa reutilizable cuando vayas a comprar. Cada bolsa de plástico tarda hasta 500 años en degradarse.',
    'Apaga las luces de las habitaciones vacías. Es un gesto pequeño que, sumado, reduce tu factura y tu huella de carbono.',
    'Hoy intenta ir andando o en bici en un trayecto que harías en coche. Tu cuerpo y el planeta ganan.',
    'Revisa la nevera antes de comprar. Un tercio de la comida producida se desperdicia. Planificar evita tirar alimentos.',
    'Usa una botella reutilizable en vez de comprar agua embotellada. Menos plástico, más ahorro.',
    'Baja la calefacción 1 grado. Apenas lo notarás, pero reduce el consumo energético un 7% aproximadamente.',
    'Compra productos de temporada y locales cuando puedas. Recorren menos kilómetros y tienen mejor sabor y nutrientes.',
    'Desenchufa cargadores y aparatos que no estés usando. El consumo en standby supone hasta un 10% de tu factura eléctrica.',
    'Reutiliza antes de reciclar. ¿Ese bote de cristal puede servir de tupper? Alargar la vida de los objetos es más eficiente que reciclarlos.',
    'Reduce el tiempo de ducha en 2 minutos. Ahorrarás unos 20 litros de agua cada vez.',
    'Antes de comprar algo nuevo, pregúntate si de verdad lo necesitas. El consumo consciente es el primer paso hacia la sostenibilidad.',
    'Separa correctamente tus residuos. Un envase bien reciclado puede volver a ser materia prima en pocas semanas.',
    'Cocina las cantidades justas para evitar sobras que acaban en la basura. Si sobra, congélalo para otro día.',
    'Elige transporte público para distancias largas. Un autobús emite hasta 5 veces menos CO₂ por pasajero que un coche.',
    'Planta algo, aunque sea una hierba aromática en la ventana. Conectar con la naturaleza te recuerda por qué cuidarla.',

    // Relaciones (5)
    'Hoy escucha activamente a alguien sin pensar en qué vas a responder. La atención plena fortalece cualquier relación.',
    'Envía un mensaje a alguien a quien hace tiempo que no escribes. Mantener relaciones requiere pequeños gestos constantes.',
    'Practica la empatía: antes de juzgar, intenta entender qué siente la otra persona y por qué actúa así.',
    'Dedica tiempo de calidad a alguien importante hoy. Sin móvil, sin distracciones, solo presencia.',
    'Da las gracias de forma específica. En vez de un "gracias" genérico, di exactamente qué aprecias y por qué.',

    // Crecimiento personal (10)
    'Lee aunque sean 10 páginas hoy. Leer a diario acumula decenas de libros al año sin que lo notes.',
    'Aprende una cosa nueva hoy, por pequeña que sea. Un atajo de teclado, una palabra en otro idioma, un dato curioso.',
    'Haz algo que te dé un poco de miedo. Crecer empieza justo donde acaba tu zona de confort.',
    'Reflexiona sobre un error reciente sin culparte. ¿Qué harías diferente? Los errores solo son pérdida si no extraes la lección.',
    'Escribe un objetivo a 3 meses. Tener un destino claro te ayuda a tomar mejores decisiones hoy.',
    'Pide feedback a alguien sobre algo que estés haciendo. La perspectiva externa descubre puntos ciegos.',
    'Dedica 15 minutos a un hobby que no sea productivo. Hacer algo solo por placer recarga tu creatividad.',
    'Escucha un podcast o charla sobre un tema que no dominas. La curiosidad es el motor del crecimiento.',
    'Revisa tus hábitos: ¿alguno ya no te aporta? Soltar lo que no funciona es tan importante como empezar cosas nuevas.',
    'Comparte algo que hayas aprendido con otra persona. Enseñar es la mejor forma de consolidar conocimiento.',
  ];

  // ─── ENGLISH ──────────────────────────────────────────────────────

  static const _tipsEn = [
    // Health & exercise (10)
    'Drink a glass of water as soon as you wake up. Your body has been dehydrated for hours and needs it to get going.',
    'Spend 5 minutes stretching before starting your day. Your back and neck will thank you, especially if you sit at a desk.',
    'Try to walk at least 20 minutes today. No need to run — walking already boosts your mood and cardiovascular health.',
    'Try meditating for 3 minutes with your eyes closed. Just focus on your breathing without judging any thoughts.',
    'Aim for 7 to 8 hours of sleep tonight. Rest is not a luxury — it is the foundation for everything else.',
    'Do 10 squats right now. Breaking inactivity with a quick movement activates your body and clears your mind.',
    'Cut back on coffee after 2 PM. Caffeine takes up to 8 hours to clear and can sabotage your sleep.',
    'Include a piece of fruit in your next meal. Small changes add up to a big transformation in your diet.',
    'Every hour, stand up and move for 2 minutes. Sitting for long stretches slows down your metabolism.',
    'Try to have dinner at least 2 hours before bed. Your digestion will be easier and you will sleep better.',

    // Productivity (10)
    'Start the day with the hardest task. Your energy and focus peak in the morning.',
    'Use the Pomodoro technique: 25 minutes of focus, 5 minutes of rest. Working in blocks beats trying to concentrate for hours.',
    'Before opening your phone, write down the 3 most important things for today. Set your priorities before others do it for you.',
    'Silence notifications while working on something important. Each interruption costs about 23 minutes to refocus.',
    'Batch similar tasks together. Answering emails, making calls, or reviewing code is more efficient in a single block.',
    'Plan tomorrow before you finish today. You will start the day with direction instead of improvising.',
    'Learn to say no. Every yes to something unimportant is a no to something that truly matters.',
    'If a task takes less than 2 minutes, do it now. Piling up small things clutters your mental list.',
    'Review your weekly progress every Friday. Knowing how far you have come is more motivating than any app.',
    'Remove one distraction from your desk today. A clean space reduces cognitive load.',

    // Mental well-being (10)
    'Write down 3 things you are grateful for today. Gratitude literally changes your brain chemistry.',
    'Disconnect from screens 30 minutes before bed. Blue light tricks your brain into thinking it is daytime.',
    'Spend 10 minutes writing your thoughts freely. Journaling helps you process emotions and find clarity.',
    'Take 5 deep breaths when you feel stressed. Slow breathing activates your parasympathetic nervous system.',
    'Try not to compare yourself to anyone on social media today. What you see is a highlight reel, not the full picture.',
    'Allow yourself a moment of doing nothing. Boredom is the space where the best ideas are born.',
    'Talk to someone you trust about how you feel. Sharing is not weakness — it is emotional intelligence.',
    'Celebrate a small win today, no matter how insignificant it seems. Recognizing progress reinforces the habit.',
    'Go outside for at least 10 minutes. Natural light regulates your circadian rhythm and lifts your mood.',
    'Accept that you do not have to be perfect today. Imperfect progress beats paralyzed perfection.',

    // Sustainability (15)
    'Bring your own reusable bag when shopping. A single plastic bag takes up to 500 years to decompose.',
    'Turn off lights in empty rooms. A small gesture that, over time, lowers your bill and your carbon footprint.',
    'Walk or cycle for a trip you would normally drive. Your body and the planet both win.',
    'Check the fridge before buying groceries. A third of all food produced is wasted — planning prevents throwing food away.',
    'Use a reusable water bottle instead of buying plastic ones. Less plastic, more savings.',
    'Lower the heating by 1 degree. You will barely notice, but it cuts energy consumption by about 7 percent.',
    'Buy seasonal and local produce when possible. It travels fewer miles and has better flavor and nutrients.',
    'Unplug chargers and devices you are not using. Standby consumption can account for up to 10 percent of your electricity bill.',
    'Reuse before recycling. Can that glass jar work as a container? Extending the life of objects is more efficient than recycling them.',
    'Shorten your shower by 2 minutes. You will save about 20 liters of water each time.',
    'Before buying something new, ask yourself if you really need it. Conscious consumption is the first step toward sustainability.',
    'Sort your waste properly. A well-recycled package can become raw material again in just weeks.',
    'Cook the right portions to avoid leftovers that end up in the bin. If there are leftovers, freeze them for another day.',
    'Choose public transport for longer distances. A bus emits up to 5 times less CO₂ per passenger than a car.',
    'Plant something, even if it is just a herb on your windowsill. Connecting with nature reminds you why it is worth protecting.',

    // Relationships (5)
    'Listen actively to someone today without thinking about your reply. Full attention strengthens any relationship.',
    'Send a message to someone you have not reached out to in a while. Maintaining relationships takes small, consistent gestures.',
    'Practice empathy: before judging, try to understand what the other person feels and why they act that way.',
    'Spend quality time with someone important today. No phone, no distractions — just presence.',
    'Give specific thanks. Instead of a generic "thanks," say exactly what you appreciate and why.',

    // Personal growth (10)
    'Read at least 10 pages today. Daily reading adds up to dozens of books a year without you noticing.',
    'Learn one new thing today, however small. A keyboard shortcut, a word in another language, a fun fact.',
    'Do something that scares you a little. Growth starts right where your comfort zone ends.',
    'Reflect on a recent mistake without blaming yourself. What would you do differently? Mistakes are only a loss if you skip the lesson.',
    'Write down a goal for the next 3 months. A clear destination helps you make better decisions today.',
    'Ask someone for feedback on something you are doing. An outside perspective reveals blind spots.',
    'Spend 15 minutes on a hobby that is not productive. Doing something purely for fun recharges your creativity.',
    'Listen to a podcast or talk on a topic you know little about. Curiosity is the engine of growth.',
    'Review your habits: is there one that no longer serves you? Letting go of what does not work is as important as starting new things.',
    'Share something you have learned with someone else. Teaching is the best way to consolidate knowledge.',
  ];

  // ─── VALENCIA / CATALA ────────────────────────────────────────────

  static const _tipsCa = [
    // Salut i exercici (10)
    'Beu un got d\'aigua en llevar-te. El teu cos porta hores sense hidratar-se i ho necessita per a arrancar.',
    'Dedica 5 minuts a estirar abans de començar el dia. L\'esquena i el coll t\'ho agrairan, sobretot si treballes assegut.',
    'Intenta caminar almenys 20 minuts hui. No cal córrer: caminar ja millora el teu estat d\'ànim i la teua salut cardiovascular.',
    'Prova a meditar 3 minuts amb els ulls tancats. Centra\'t en la respiració sense jutjar els pensaments que apareguen.',
    'Dorm entre 7 i 8 hores esta nit. El descans no és un luxe, és la base de tot el demés.',
    'Fes 10 sentadetes ara mateix. Trencar la inactivitat amb un moviment ràpid activa el cos i aclareix la ment.',
    'Redueix el café després de les 14h. La cafeïna tarda fins a 8 hores a eliminar-se i pot sabotejar el teu son.',
    'Inclou una peça de fruita en el teu pròxim menjar. Xicotets canvis acumulats transformen la teua alimentació.',
    'Cada hora, alça\'t i mou-te 2 minuts. Estar assegut molt de temps seguit alenteix el metabolisme.',
    'Prova a sopar almenys 2 hores abans de dormir. La digestió serà més fàcil i dormiràs millor.',

    // Productivitat (10)
    'Comença el dia per la tasca més difícil. La teua energia i concentració són màximes pel matí.',
    'Usa la tècnica Pomodoro: 25 minuts de focus i 5 de descans. És millor treballar en blocs que intentar concentrar-te hores seguides.',
    'Abans d\'obrir el mòbil, escriu les 3 coses més importants de hui. Decideix les teues prioritats abans que altres ho facen per tu.',
    'Silencia les notificacions mentre treballes en algo important. Cada interrupció costa uns 23 minuts de refocus.',
    'Agrupa tasques semblants. Respondre emails, fer trucades o revisar codi rendeix més si ho fas seguit.',
    'Planifica demà abans d\'acabar hui. Començaràs el dia amb direcció en lloc d\'improvisar.',
    'Aprén a dir no. Cada sí a algo poc important és un no a algo que de debò t\'importa.',
    'Si una tasca et porta menys de 2 minuts, fes-la ara. Acumular menudeses satura la teua llista mental.',
    'Revisa el teu progrés setmanal cada divendres. Saber quant has avançat et motiva més que qualsevol app.',
    'Elimina una distracció del teu escriptori hui. Un espai net redueix la càrrega cognitiva.',

    // Benestar mental (10)
    'Escriu 3 coses per les quals estàs agraït hui. La gratitud canvia literalment la química del teu cervell.',
    'Desconnecta\'t de les pantalles 30 minuts abans de dormir. La llum blava enganya el cervell fent-li creure que és de dia.',
    'Dedica 10 minuts a escriure el que penses sense filtre. El journaling t\'ajuda a processar emocions i trobar claredat.',
    'Respira profundament 5 vegades quan sentes estrés. La respiració lenta activa el sistema nerviós parasimpàtic.',
    'Hui intenta no comparar-te amb ningú a les xarxes socials. El que veus és una selecció, no la realitat completa.',
    'Permet-te un moment de no fer res. L\'avorriment és l\'espai on naixen les millors idees.',
    'Parla amb algú de confiança sobre com et sents. Compartir no és debilitat, és intel·ligència emocional.',
    'Celebra un xicotet assoliment de hui, per insignificant que parega. Reconéixer l\'avanç reforça l\'hàbit.',
    'Ix a l\'aire lliure almenys 10 minuts. La llum natural regula el teu ritme circadiari i millora el teu ànim.',
    'Accepta que hui no has de ser perfecte. El progrés imperfecte supera la perfecció paralitzada.',

    // Sostenibilitat (15)
    'Porta la teua pròpia bossa reutilitzable quan vages a comprar. Cada bossa de plàstic tarda fins a 500 anys a degradar-se.',
    'Apaga els llums de les habitacions buides. És un gest xicotet que, sumat, redueix la teua factura i la teua petjada de carboni.',
    'Hui intenta anar caminant o en bici en un trajecte que faries en cotxe. El teu cos i el planeta guanyen.',
    'Revisa la nevera abans de comprar. Un terç del menjar produït es malbarata. Planificar evita tirar aliments.',
    'Usa una botella reutilitzable en compte de comprar aigua embotellada. Menys plàstic, més estalvi.',
    'Baixa la calefacció 1 grau. Quasi no ho notaràs, però redueix el consum energètic un 7% aproximadament.',
    'Compra productes de temporada i locals quan pugues. Recorren menys quilòmetres i tenen millor sabor i nutrients.',
    'Desendolla carregadors i aparells que no estigues usant. El consum en standby suposa fins a un 10% de la teua factura elèctrica.',
    'Reutilitza abans de reciclar. Eixe pot de vidre pot servir de tupper? Allargar la vida dels objectes és més eficient que reciclar-los.',
    'Redueix el temps de dutxa en 2 minuts. Estalviaràs uns 20 litres d\'aigua cada vegada.',
    'Abans de comprar algo nou, pregunta\'t si de debò ho necessites. El consum conscient és el primer pas cap a la sostenibilitat.',
    'Separa correctament els teus residus. Un envàs ben reciclat pot tornar a ser matèria primera en poques setmanes.',
    'Cuina les quantitats justes per a evitar sobres que acaben a la brossa. Si en sobra, congela-ho per a un altre dia.',
    'Tria transport públic per a distàncies llargues. Un autobús emet fins a 5 vegades menys CO₂ per passatger que un cotxe.',
    'Planta alguna cosa, encara que siga una herba aromàtica a la finestra. Connectar amb la natura et recorda per què cuidar-la.',

    // Relacions (5)
    'Hui escolta activament a algú sense pensar en què vas a respondre. L\'atenció plena enforteix qualsevol relació.',
    'Envia un missatge a algú a qui fa temps que no escrius. Mantenir relacions requereix xicotets gestos constants.',
    'Practica l\'empatia: abans de jutjar, intenta entendre què sent l\'altra persona i per què actua així.',
    'Dedica temps de qualitat a algú important hui. Sense mòbil, sense distraccions, només presència.',
    'Dona les gràcies de forma específica. En compte d\'un "gràcies" genèric, digues exactament què aprecias i per què.',

    // Creixement personal (10)
    'Llig encara que siguen 10 pàgines hui. Llegir a diari acumula desenes de llibres a l\'any sense que ho notes.',
    'Aprén una cosa nova hui, per xicoteta que siga. Una drecera de teclat, una paraula en un altre idioma, una dada curiosa.',
    'Fes alguna cosa que et done una mica de por. Créixer comença just on acaba la teua zona de confort.',
    'Reflexiona sobre un error recent sense culpar-te. Què faries diferent? Els errors només són pèrdua si no n\'extraus la lliçó.',
    'Escriu un objectiu a 3 mesos. Tindre un destí clar t\'ajuda a prendre millors decisions hui.',
    'Demana feedback a algú sobre alguna cosa que estigues fent. La perspectiva externa descobreix punts cecs.',
    'Dedica 15 minuts a un hobby que no siga productiu. Fer alguna cosa només per plaer recarrega la teua creativitat.',
    'Escolta un podcast o xarrada sobre un tema que no domines. La curiositat és el motor del creixement.',
    'Revisa els teus hàbits: algun ja no t\'aporta? Soltar el que no funciona és tan important com començar coses noves.',
    'Comparteix alguna cosa que hages aprés amb una altra persona. Ensenyar és la millor forma de consolidar coneixement.',
  ];
}
