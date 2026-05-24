-- ============================================================
-- ISLAM QUEST — Schema + 40 Questions Seed
-- Run entirely in Supabase SQL Editor (not prisma migrate)
-- ============================================================

-- Tables
CREATE TABLE IF NOT EXISTS questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  texte TEXT NOT NULL,
  niveau TEXT NOT NULL CHECK (niveau IN ('facile', 'moyen', 'difficile')),
  categorie TEXT NOT NULL CHECK (categorie IN ('piliers','coran','hadith','histoire','jurisprudence','prophetes','foi')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  texte TEXT NOT NULL,
  est_correct BOOLEAN NOT NULL DEFAULT FALSE,
  ordre INTEGER NOT NULL CHECK (ordre BETWEEN 0 AND 3)
);

CREATE TABLE IF NOT EXISTS dalils (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID NOT NULL UNIQUE REFERENCES questions(id) ON DELETE CASCADE,
  explication TEXT NOT NULL,
  texte_arabe TEXT NOT NULL,
  traduction TEXT NOT NULL,
  reference TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pseudo TEXT NOT NULL,
  niveau TEXT NOT NULL,
  categorie TEXT NOT NULL,
  score INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  ended_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS session_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES questions(id),
  reponse_index INTEGER,
  est_correct BOOLEAN,
  answered_at TIMESTAMPTZ,
  ordre INTEGER NOT NULL
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_questions_niveau ON questions(niveau);
CREATE INDEX IF NOT EXISTS idx_questions_categorie ON questions(categorie);
CREATE INDEX IF NOT EXISTS idx_options_question ON options(question_id);
CREATE INDEX IF NOT EXISTS idx_dalils_question ON dalils(question_id);
CREATE INDEX IF NOT EXISTS idx_session_answers_session ON session_answers(session_id);

-- ============================================================
-- SEED: 40 Questions (facile x15, moyen x15, difficile x10)
-- ============================================================
DO $$
DECLARE q UUID;
BEGIN

-- Q1 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de piliers l''Islam possède-t-il ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'4 piliers',false,0),(q,'5 piliers',true,1),(q,'6 piliers',false,2),(q,'7 piliers',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''Islam repose sur cinq piliers fondamentaux : la Shahada, la Salah, la Zakat, le Sawm et le Hajj.',
   'بُنِيَ الإِسْلَامُ عَلَى خَمْسٍ: شَهَادَةِ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَنَّ مُحَمَّدًا رَسُولُ اللَّهِ، وَإِقَامِ الصَّلَاةِ، وَإِيتَاءِ الزَّكَاةِ، وَالْحَجِّ، وَصَوْمِ رَمَضَانَ',
   'L''Islam est bâti sur cinq piliers : témoigner qu''il n''y a de divinité qu''Allah et que Muhammad est Son messager, accomplir la prière, acquitter la Zakat, accomplir le Hajj et jeûner le Ramadan.',
   'Sahih Bukhari — Hadith n°8');

-- Q2 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le premier pilier de l''Islam ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La Prière (Salah)',false,0),(q,'La Shahada (témoignage de foi)',true,1),(q,'Le Jeûne (Sawm)',false,2),(q,'La Zakat',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Shahada est le fondement de l''Islam. Quiconque la prononce sincèrement entre en Islam.',
   'أُمِرْتُ أَنْ أُقَاتِلَ النَّاسَ حَتَّى يَشْهَدُوا أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَنَّ مُحَمَّدًا رَسُولُ اللَّهِ',
   'Il m''a été ordonné de combattre les gens jusqu''à ce qu''ils témoignent qu''il n''y a de divinité qu''Allah et que Muhammad est Son messager.',
   'Sahih Bukhari — Hadith n°25');

-- Q3 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de prières obligatoires y a-t-il par jour ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'3 prières',false,0),(q,'4 prières',false,1),(q,'5 prières',true,2),(q,'6 prières',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Allah a prescrit cinq prières quotidiennes lors du Mi''raj. Elles valent cinquante en récompense.',
   'فَرَجَعْتُ إِلَى رَبِّي فَقُلْتُ: يَا رَبِّ خَفِّفْ عَلَى أُمَّتِي، فَوُضِعَتْ خَمْسُ صَلَوَاتٍ',
   'Je retournai vers mon Seigneur et dis : Ô Seigneur, allège le fardeau de ma communauté. Les prières furent alors réduites à cinq.',
   'Sahih Bukhari — Hadith n°349');

-- Q4 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de sourates contient le Coran ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'100 sourates',false,0),(q,'112 sourates',false,1),(q,'114 sourates',true,2),(q,'120 sourates',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Coran comprend 114 sourates, de Al-Fatiha (la première) à An-Nas (la dernière). Allah en est le gardien.',
   'إِنَّا نَحْنُ نَزَّلْنَا الذِّكْرَ وَإِنَّا لَهُ لَحَافِظُونَ',
   'C''est Nous qui avons fait descendre le Rappel, et c''est Nous qui en sommes les gardiens.',
   'Sourate Al-Hijr (15:9)');

-- Q5 (facile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom du dernier prophète envoyé par Allah ?', 'facile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Issa (Jésus)',false,0),(q,'Ibrahim (Abraham)',false,1),(q,'Muhammad ﷺ',true,2),(q,'Moussa (Moïse)',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Muhammad ﷺ est le Sceau des prophètes. Aucun prophète ne viendra après lui.',
   'مَا كَانَ مُحَمَّدٌ أَبَا أَحَدٍ مِّن رِّجَالِكُمْ وَلَٰكِن رَّسُولَ اللَّهِ وَخَاتَمَ النَّبِيِّينَ',
   'Muhammad n''est pas le père d''aucun de vos hommes, mais il est le Messager d''Allah et le Sceau des prophètes.',
   'Sourate Al-Ahzab (33:40)');

-- Q6 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Dans quel mois les musulmans jeûnent-ils ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Muharram',false,0),(q,'Rajab',false,1),(q,'Ramadan',true,2),(q,'Sha''ban',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le jeûne du mois de Ramadan est le quatrième pilier de l''Islam. C''est le mois de la révélation du Coran.',
   'شَهْرُ رَمَضَانَ الَّذِي أُنزِلَ فِيهِ الْقُرْآنُ هُدًى لِّلنَّاسِ فَمَن شَهِدَ مِنكُمُ الشَّهْرَ فَلْيَصُمْهُ',
   'Le mois de Ramadan est celui durant lequel le Coran a été révélé comme guide pour les hommes. Quiconque d''entre vous est présent ce mois doit le jeûner.',
   'Sourate Al-Baqarah (2:185)');

-- Q7 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est la première sourate du Coran ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Al-Baqarah',false,0),(q,'Al-Fatiha',true,1),(q,'An-Nas',false,2),(q,'Al-Ikhlas',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Al-Fatiha (l''Ouverture) est la première sourate du Coran. Elle est aussi appelée Umm Al-Quran (la mère du Coran).',
   'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
   'Louange à Allah, Seigneur des mondes.',
   'Sourate Al-Fatiha (1:2)');

-- Q8 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de fois le pèlerinage (Hajj) est-il obligatoire dans une vie ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Chaque année',false,0),(q,'Une seule fois',true,1),(q,'Deux fois',false,2),(q,'Trois fois',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Hajj est obligatoire une seule fois dans la vie pour tout musulman qui en a la capacité physique et financière.',
   'وَلِلَّهِ عَلَى النَّاسِ حِجُّ الْبَيْتِ مَنِ اسْتَطَاعَ إِلَيْهِ سَبِيلًا',
   'C''est pour Allah un droit sur les hommes de faire le pèlerinage de la Maison, pour ceux qui peuvent s''y rendre.',
   'Sourate Aal-Imran (3:97)');

-- Q9 (facile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est la ville la plus sacrée en Islam ?', 'facile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Médine',false,0),(q,'Jérusalem',false,1),(q,'La Mecque',true,2),(q,'Damas',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Mecque est la ville la plus sacrée en Islam, car elle abrite la Kaaba, première maison de culte construite pour l''humanité.',
   'إِنَّ أَوَّلَ بَيْتٍ وُضِعَ لِلنَّاسِ لَلَّذِي بِبَكَّةَ مُبَارَكًا وَهُدًى لِّلْعَالَمِينَ',
   'La première Maison qui ait été établie pour les gens est celle de Bakka (La Mecque), une maison bénie et une direction pour les mondes.',
   'Sourate Aal-Imran (3:96)');

-- Q10 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Zakat ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le pèlerinage à La Mecque',false,0),(q,'La prière du vendredi',false,1),(q,'L''aumône légale obligatoire',true,2),(q,'Le jeûne du lundi',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Zakat est le troisième pilier de l''Islam. Elle purifie la richesse et aide les nécessiteux. Le taux standard est 2,5% sur l''épargne dépassant le nisab.',
   'وَأَقِيمُوا الصَّلَاةَ وَآتُوا الزَّكَاةَ وَارْكَعُوا مَعَ الرَّاكِعِينَ',
   'Accomplissez la prière, acquittez la Zakat et inclinez-vous avec ceux qui s''inclinent.',
   'Sourate Al-Baqarah (2:43)');

-- Q11 (facile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel ange a apporté la révélation au Prophète ﷺ ?', 'facile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Mikail (Michel)',false,0),(q,'Israfil',false,1),(q,'Jibreel (Gabriel)',true,2),(q,'Azrail',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''ange Jibreel (Gabriel) est celui qui a transmis la révélation coranique au Prophète Muhammad ﷺ par ordre d''Allah.',
   'قُلْ مَن كَانَ عَدُوًّا لِّجِبْرِيلَ فَإِنَّهُ نَزَّلَهُ عَلَىٰ قَلْبِكَ بِإِذْنِ اللَّهِ',
   'Dis : Quiconque est ennemi de Jibreel — c''est lui qui l''a fait descendre sur ton cœur, par permission d''Allah.',
   'Sourate Al-Baqarah (2:97)');

-- Q12 (facile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de rak''at contient la prière du Fajr (aube) ?', 'facile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'1 rak''a',false,0),(q,'2 rak''at',true,1),(q,'3 rak''at',false,2),(q,'4 rak''at',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La prière du Fajr comprend 2 rak''at obligatoires (fard). C''est la plus courte des cinq prières quotidiennes.',
   'أَقِمِ الصَّلَاةَ لِدُلُوكِ الشَّمْسِ إِلَىٰ غَسَقِ اللَّيْلِ وَقُرْآنَ الْفَجْرِ إِنَّ قُرْآنَ الْفَجْرِ كَانَ مَشْهُودًا',
   'Accomplis la prière du déclin du soleil jusqu''à l''obscurité de la nuit, et la récitation de l''aube, car la récitation de l''aube est attestée.',
   'Sourate Al-Isra (17:78)');

-- Q13 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est la plus courte sourate du Coran ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Al-Ikhlas',false,0),(q,'An-Nasr',false,1),(q,'Al-Kawthar',true,2),(q,'Al-Falaq',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Al-Kawthar est la plus courte sourate du Coran avec seulement 3 versets. Elle annonce le don de l''Abondance au Prophète ﷺ.',
   'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ ۝ فَصَلِّ لِرَبِّكَ وَانْحَرْ ۝ إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ',
   'Nous t''avons donné l''Abondance. Accomplis donc la prière pour ton Seigneur et sacrifie. Certes, c''est ton adversaire qui est sans postérité.',
   'Sourate Al-Kawthar (108:1-3)');

-- Q14 (facile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète a construit le bateau pour survivre au déluge ?', 'facile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Ibrahim',false,0),(q,'Moussa',false,1),(q,'Nuh (Noé)',true,2),(q,'Yusuf',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Allah ordonna à Nuh (Noé) de construire l''arche pour sauver les croyants et les animaux du grand déluge.',
   'وَاصْنَعِ الْفُلْكَ بِأَعْيُنِنَا وَوَحْيِنَا وَلَا تُخَاطِبْنِي فِي الَّذِينَ ظَلَمُوا',
   'Construis l''Arche sous Nos yeux et selon Notre révélation, et ne M''implore pas en faveur de ceux qui ont commis des injustices.',
   'Sourate Hud (11:37)');

-- Q15 (facile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom du père d''Ibrahim mentionné dans le Coran ?', 'facile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Yaʿqub',false,0),(q,'Ishaq',false,1),(q,'Azar',true,2),(q,'Imran',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Coran mentionne explicitement que le père d''Ibrahim s''appelait Azar. Ibrahim l''exhorta à abandonner l''idolâtrie.',
   'وَإِذْ قَالَ إِبْرَاهِيمُ لِأَبِيهِ آزَرَ أَتَتَّخِذُ أَصْنَامًا آلِهَةً',
   'Et lorsque Ibrahim dit à son père Azar : Prends-tu des idoles pour divinités ?',
   'Sourate Al-An''am (6:74)');

-- Q16 (moyen / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de prophètes sont mentionnés nominalement dans le Coran ?', 'moyen', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'18 prophètes',false,0),(q,'20 prophètes',false,1),(q,'25 prophètes',true,2),(q,'30 prophètes',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Coran mentionne 25 prophètes par leur nom. Il y en a eu bien d''autres dont Allah n''a pas mentionné l''histoire.',
   'وَرُسُلًا قَدْ قَصَصْنَاهُمْ عَلَيْكَ مِن قَبْلُ وَرُسُلًا لَّمْ نَقْصُصْهُمْ عَلَيْكَ',
   'Et des messagers dont Nous t''avons déjà relaté l''histoire, et des messagers dont Nous ne t''avons pas relaté l''histoire.',
   'Sourate An-Nisa (4:164)');

-- Q17 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Dans quelle ville le Prophète Muhammad ﷺ est-il né ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Médine',false,0),(q,'Taif',false,1),(q,'La Mecque',true,2),(q,'Jérusalem',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Prophète Muhammad ﷺ est né à La Mecque vers 570 CE (l''Année de l''Éléphant), dans la famille des Banu Hashim de la tribu des Quraysh.',
   'أَنَا دَعْوَةُ أَبِي إِبْرَاهِيمَ وَبُشْرَى عِيسَى وَرَأَتْ أُمِّي حِينَ حَمَلَتْ بِي كَأَنَّهُ خَرَجَ مِنْهَا نُورٌ أَضَاءَتْ لَهُ قُصُورُ الشَّامِ',
   'Je suis la supplication de mon père Ibrahim, l''annonce de mon frère Issa, et ma mère vit en rêve qu''une lumière sortait d''elle et éclairait les palais de Syrie.',
   'Musnad Ahmad — Hadith authentifié par Al-Albani');

-- Q18 (moyen / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète a été jeté dans un puits par ses propres frères ?', 'moyen', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Moussa',false,0),(q,'Ibrahim',false,1),(q,'Yusuf (Joseph)',true,2),(q,'Yunus',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les frères de Yusuf, jaloux de l''amour que leur père Ya''qub lui portait, le jetèrent au fond d''un puits. Allah en fit une épreuve et une élévation pour Yusuf.',
   'وَأَجْمَعُوا أَن يَجْعَلُوهُ فِي غَيَابَتِ الْجُبِّ',
   'Ils se mirent d''accord pour le mettre au fond du puits.',
   'Sourate Yusuf (12:15)');

-- Q19 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle sourate est surnommée "le cœur du Coran" ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Al-Baqarah',false,0),(q,'Al-Fatiha',false,1),(q,'Yaseen',true,2),(q,'Al-Kahf',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Prophète ﷺ a décrit Yaseen comme le cœur du Coran. Il est recommandé de la réciter pour les mourants et en l''honneur des défunts.',
   'إِنَّ لِكُلِّ شَيْءٍ قَلْبًا، وَإِنَّ قَلْبَ الْقُرْآنِ يس',
   'Tout a un cœur, et le cœur du Coran est Yaseen.',
   'Sunan At-Tirmidhi — Hadith n°2887');

-- Q20 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qui fut le premier calife après le décès du Prophète ﷺ ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Umar ibn Al-Khattab',false,0),(q,'Ali ibn Abi Talib',false,1),(q,'Abu Bakr As-Siddiq',true,2),(q,'Uthman ibn Affan',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Abu Bakr As-Siddiq fut élu premier calife lors de la Saqifa. Le Prophète ﷺ lui avait accordé une place particulière de son vivant.',
   'لَوْ كُنْتُ مُتَّخِذًا خَلِيلًا مِنَ النَّاسِ لَاتَّخَذْتُ أَبَا بَكْرٍ خَلِيلًا، وَلَكِنَّهُ أَخِي وَصَاحِبِي',
   'Si j''avais dû prendre un ami intime parmi les humains, j''aurais pris Abu Bakr. Mais il est mon frère et mon compagnon.',
   'Sahih Bukhari — Hadith n°3656');

-- Q21 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nombre de versets du Coran selon le décompte le plus répandu ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'6000 versets',false,0),(q,'6236 versets',true,1),(q,'6500 versets',false,2),(q,'7000 versets',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le décompte le plus répandu est 6236 versets (selon la transmission de Hafs ''an Asim). Allah a promis de préserver Son Livre.',
   'وَلَقَدْ يَسَّرْنَا الْقُرْآنَ لِلذِّكْرِ فَهَلْ مِن مُّدَّكِرٍ',
   'Nous avons facilité le Coran pour la remémoration. Y a-t-il quelqu''un pour s''en souvenir ?',
   'Sourate Al-Qamar (54:17)');

-- Q22 (moyen / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le plus grand péché en Islam ?', 'moyen', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le meurtre d''un innocent',false,0),(q,'Le mensonge délibéré',false,1),(q,'Le shirk (associer à Allah)',true,2),(q,'La zina (fornication)',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le shirk (polythéisme) est le seul péché qu''Allah ne pardonne pas si l''on meurt sans en avoir fait repentance. Tous les autres péchés peuvent être pardonnés.',
   'إِنَّ اللَّهَ لَا يَغْفِرُ أَن يُشْرَكَ بِهِ وَيَغْفِرُ مَا دُونَ ذَٰلِكَ لِمَن يَشَاءُ',
   'Certes, Allah ne pardonne pas qu''on Lui associe quelque chose, mais Il pardonne à qui Il veut ce qui est moins grave que cela.',
   'Sourate An-Nisa (4:48)');

-- Q23 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Comment s''appelle la nuit plus précieuse que mille mois ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La nuit du Mi''raj',false,0),(q,'La nuit du 15 Sha''ban',false,1),(q,'Laylat Al-Qadr (la nuit du Destin)',true,2),(q,'La nuit de la naissance du Prophète',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Laylat Al-Qadr se trouve dans les dix dernières nuits du Ramadan, probablement une nuit impaire. Son adoration vaut plus de 83 ans d''adoration.',
   'لَيْلَةُ الْقَدْرِ خَيْرٌ مِّنْ أَلْفِ شَهْرٍ',
   'La Nuit du Destin est meilleure que mille mois.',
   'Sourate Al-Qadr (97:3)');

-- Q24 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qui a ordonné l''unification du Coran en un Mushaf standard ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Umar ibn Al-Khattab',false,0),(q,'Abu Bakr As-Siddiq',false,1),(q,'Uthman ibn Affan',true,2),(q,'Ali ibn Abi Talib',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le calife Uthman ibn Affan ordonna la compilation d''un Mushaf standard pour unifier la lecture du Coran et prévenir les divergences entre les musulmans des différentes régions.',
   'أَنَّ عُثْمَانَ أَمَرَ زَيْدَ بْنَ ثَابِتٍ وَعَبْدَ اللَّهِ بْنَ الزُّبَيْرِ وَسَعِيدَ بْنَ الْعَاصِ وَعَبْدَ الرَّحْمَنِ بْنَ الْحَارِثِ أَنْ يَنْسَخُوا الصُّحُفَ فِي الْمَصَاحِفِ',
   'Uthman ordonna à Zayd ibn Thabit, Abd Allah ibn Al-Zubayr, Said ibn Al-As et Abd Al-Rahman ibn Al-Harith de copier les feuillets en des Mushafs.',
   'Sahih Bukhari — Hadith n°4987');

-- Q25 (moyen / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète a été avalé par une baleine ?', 'moyen', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Moussa',false,0),(q,'Ibrahim',false,1),(q,'Issa',false,2),(q,'Yunus (Jonas)',true,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Yunus quitta son peuple sans permission divine. Une baleine l''avala. Il fit repentance dans ses entrailles et Allah l''en délivra.',
   'فَالْتَقَمَهُ الْحُوتُ وَهُوَ مُلِيمٌ',
   'Alors le poisson l''avala, tandis qu''il était blâmable.',
   'Sourate As-Saffat (37:142)');

-- Q26 (moyen / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est l''épouse du Pharaon qui protégea Moussa (Moïse) ?', 'moyen', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Khadija',false,0),(q,'Maryam',false,1),(q,'Bilqis',false,2),(q,'Asiya',true,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Asiya bint Muzahim, épouse de Pharaon, recueillit Moussa bébé et lui sauva la vie. Elle est l''une des quatre femmes les plus parfaites que l''Islam reconnaît.',
   'وَضَرَبَ اللَّهُ مَثَلًا لِّلَّذِينَ آمَنُوا امْرَأَتَ فِرْعَوْنَ إِذْ قَالَتْ رَبِّ ابْنِ لِي عِندَكَ بَيْتًا فِي الْجَنَّةِ',
   'Allah cite en exemple pour les croyants la femme de Pharaon, lorsqu''elle dit : Seigneur, construis-moi auprès de Toi une demeure au Paradis.',
   'Sourate At-Tahrim (66:11)');

-- Q27 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien d''années a duré la révélation coranique ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'10 ans',false,0),(q,'20 ans',false,1),(q,'23 ans',true,2),(q,'40 ans',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La révélation coranique a commencé en 610 CE avec la sourate Al-''Alaq et s''est terminée en 632 CE, soit 23 ans. Allah l''a révélée progressivement pour affermir le cœur du Prophète.',
   'وَقُرْآنًا فَرَقْنَاهُ لِتَقْرَأَهُ عَلَى النَّاسِ عَلَىٰ مُكْثٍ وَنَزَّلْنَاهُ تَنزِيلًا',
   'Et c''est un Coran que Nous avons distribué en parcelles afin que tu le lises aux gens avec lenteur ; Nous l''avons fait descendre en une révélation successive.',
   'Sourate Al-Isra (17:106)');

-- Q28 (moyen / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le sens littéral du mot "Islam" en arabe ?', 'moyen', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La paix absolue',false,0),(q,'La foi totale',false,1),(q,'La soumission à Allah',true,2),(q,'L''obéissance au Prophète',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Islam vient de la racine arabe "salama" qui signifie soumission et paix. Le vrai croyant trouve la paix intérieure dans sa soumission à Allah.',
   'إِنَّ الدِّينَ عِندَ اللَّهِ الْإِسْلَامُ',
   'Certes, la religion auprès d''Allah, c''est l''Islam.',
   'Sourate Aal-Imran (3:19)');

-- Q29 (moyen / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de rak''at contient la prière du Dhuhr (milieu de journée) ?', 'moyen', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'2 rak''at',false,0),(q,'3 rak''at',false,1),(q,'4 rak''at',true,2),(q,'6 rak''at',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La prière du Dhuhr comprend 4 rak''at obligatoires. C''est la deuxième prière quotidienne, accomplie après le zénith solaire.',
   'حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ وَقُومُوا لِلَّهِ قَانِتِينَ',
   'Observez scrupuleusement les prières, surtout la prière du milieu, et tenez-vous debout devant Allah en toute dévotion.',
   'Sourate Al-Baqarah (2:238)');

-- Q30 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est la signification de "As-Siddiq", le surnom d''Abu Bakr ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le courageux',false,0),(q,'Le véridique / celui qui confirme la vérité',true,1),(q,'Le savant',false,2),(q,'Le généreux',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Abu Bakr reçut le surnom d''As-Siddiq car il fut le premier à croire sans hésitation au récit du Mi''raj et à toujours confirmer la vérité apportée par le Prophète ﷺ.',
   'أَبُو بَكْرٍ أَفْضَلُ النَّاسِ بَعْدَ النَّبِيِّينَ وَالْمُرْسَلِينَ',
   'Abu Bakr est le meilleur des hommes après les prophètes et les messagers.',
   'Musnad Ahmad — Hadith authentifié');

-- Q31 (difficile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel fut le premier verset du Coran révélé au Prophète ﷺ ?', 'difficile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Al-Fatiha verset 1',false,0),(q,'"Iqra !" — Al-Alaq 96:1',true,1),(q,'Al-Baqarah verset 1',false,2),(q,'Al-Muddaththir 74:1',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Prophète ﷺ reçut la première révélation dans la grotte de Hira. Jibreel lui dit "Iqra !" (Lis !) — c''est le premier mot révélé du Coran.',
   'اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ ۝ خَلَقَ الْإِنسَانَ مِنْ عَلَقٍ',
   'Lis au nom de ton Seigneur qui a créé ! Il a créé l''homme d''une adhérence.',
   'Sourate Al-Alaq (96:1-2) — Premier verset révélé, confirmé par Sahih Bukhari n°3');

-- Q32 (difficile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Comment s''appelait la monture du Prophète ﷺ lors du voyage nocturne (Isra) ?', 'difficile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Duldul',false,0),(q,'Rafraf',false,1),(q,'Al-Buraq',true,2),(q,'Hayzan',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Al-Buraq est la monture céleste blanche qui transporta le Prophète ﷺ de La Mecque à Jérusalem lors du voyage nocturne (Isra). Sa foulée atteignait l''horizon.',
   'أُتِيَ رَسُولُ اللَّهِ ﷺ بِالْبُرَاقِ وَهُوَ دَابَّةٌ أَبْيَضُ طَوِيلٌ فَوْقَ الْحِمَارِ وَدُونَ الْبَغْلِ',
   'On apporta au Messager d''Allah Al-Buraq, une monture blanche, plus grande qu''un âne et plus petite qu''un mulet.',
   'Sahih Muslim — Hadith n°162');

-- Q33 (difficile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel sahabi fut surnommé "Sayf Allah" (l''Épée d''Allah) ?', 'difficile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Ali ibn Abi Talib',false,0),(q,'Umar ibn Al-Khattab',false,1),(q,'Khalid ibn Al-Walid',true,2),(q,'Az-Zubayr ibn Al-Awwam',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Khalid ibn Al-Walid reçut ce titre du Prophète ﷺ lui-même. Il fut invaincu dans toutes ses batailles et remporta plus de cent victoires au service de l''Islam.',
   'خَالِدُ بْنُ الْوَلِيدِ سَيْفٌ مِنْ سُيُوفِ اللَّهِ سَلَّهُ اللَّهُ عَلَى الْمُشْرِكِينَ',
   'Khalid ibn Al-Walid est une épée parmi les épées d''Allah ; Allah l''a tirée contre les associateurs.',
   'Sahih Bukhari — Hadith n°4262');

-- Q34 (difficile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Dans quelle bataille les 313 musulmans ont-ils vaincu 1000 qurayshites ?', 'difficile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La bataille d''Uhud',false,0),(q,'La bataille du Fossé (Khandaq)',false,1),(q,'La bataille de Badr',true,2),(q,'La bataille de Khaybar',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La bataille de Badr (624 CE / 2H) fut la première grande victoire des musulmans. 313 croyants mal équipés vainquirent une armée de 1000 qurayshites avec l''aide d''Allah.',
   'وَلَقَدْ نَصَرَكُمُ اللَّهُ بِبَدْرٍ وَأَنتُمْ أَذِلَّةٌ فَاتَّقُوا اللَّهَ لَعَلَّكُمْ تَشْكُرُونَ',
   'Allah vous a déjà secourus à Badr, alors que vous étiez dans la faiblesse. Craignez Allah, peut-être serez-vous reconnaissants.',
   'Sourate Aal-Imran (3:123)');

-- Q35 (difficile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom de la mère du Prophète Muhammad ﷺ ?', 'difficile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Fatima bint Assad',false,0),(q,'Khadija bint Khuwaylid',false,1),(q,'Aminah bint Wahb',true,2),(q,'Asma bint Umays',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La mère du Prophète ﷺ s''appelait Aminah bint Wahb. Elle décéda quand Muhammad avait 6 ans. Son père Abdullah décéda avant sa naissance.',
   'وَوَجَدَكَ يَتِيمًا فَآوَىٰ',
   'Ne t''a-t-Il pas trouvé orphelin ? Il t''a alors accueilli.',
   'Sourate Ad-Duha (93:6)');

-- Q36 (difficile / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce qu''un "Hadith Qudsi" ?', 'difficile', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un hadith inventé (fabrication)',false,0),(q,'Un verset coranique commenté par le Prophète',false,1),(q,'Un hadith dont le sens vient d''Allah mais les mots sont du Prophète ﷺ',true,2),(q,'Un hadith rapporté par un seul transmetteur',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Hadith Qudsi est une parole sacrée : le sens vient d''Allah, mais c''est le Prophète ﷺ qui l''exprime avec ses propres mots — contrairement au Coran dont les mots sont directement ceux d''Allah.',
   'قَالَ اللَّهُ تَعَالَى: أَنَا عِنْدَ ظَنِّ عَبْدِي بِي وَأَنَا مَعَهُ إِذَا ذَكَرَنِي',
   'Allah Le Très-Haut dit : Je suis auprès de ce que Mon serviteur pense de Moi, et Je suis avec lui quand il Me mentionne.',
   'Sahih Bukhari — Hadith Qudsi n°6970');

-- Q37 (difficile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel fut le premier masjid construit par le Prophète ﷺ après l''Hégire ?', 'difficile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Masjid Al-Haram',false,0),(q,'Masjid Al-Nabawi',false,1),(q,'Masjid Quba',true,2),(q,'Masjid Al-Aqsa',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Masjid Quba fut le premier masjid construit en Islam, lors de l''arrivée du Prophète ﷺ à Médine en 622 CE. Il est mentionné dans le Coran.',
   'لَمَسْجِدٌ أُسِّسَ عَلَى التَّقْوَىٰ مِنْ أَوَّلِ يَوْمٍ أَحَقُّ أَن تَقُومَ فِيهِ',
   'Une mosquée fondée dès le premier jour sur la piété est certes plus digne d''y prier.',
   'Sourate At-Tawbah (9:108)');

-- Q38 (difficile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('À quel âge le Prophète Muhammad ﷺ est-il décédé ?', 'difficile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'55 ans',false,0),(q,'57 ans',false,1),(q,'63 ans',true,2),(q,'70 ans',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Prophète ﷺ est décédé le 12 Rabi Al-Awwal de l''an 11 de l''Hégire (633 CE), à l''âge de 63 ans, à Médine.',
   'تُوُفِّيَ رَسُولُ اللَّهِ ﷺ وَهُوَ ابْنُ ثَلَاثٍ وَسِتِّينَ',
   'Le Messager d''Allah est décédé à l''âge de soixante-trois ans.',
   'Sahih Bukhari — Hadith n°3536');

-- Q39 (difficile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est la seule femme dont le nom est explicitement mentionné dans le Coran ?', 'difficile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Khadija',false,0),(q,'Maryam (Marie)',true,1),(q,'Asiya',false,2),(q,'Fatima',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Maryam (Marie) est la seule femme nommée dans le Coran. Elle a même une sourate entière à son nom (sourate 19). Allah l''a choisie parmi toutes les femmes.',
   'وَإِذْ قَالَتِ الْمَلَائِكَةُ يَا مَرْيَمُ إِنَّ اللَّهَ اصْطَفَاكِ وَطَهَّرَكِ وَاصْطَفَاكِ عَلَىٰ نِسَاءِ الْعَالَمِينَ',
   'Et quand les anges dirent : Ô Maryam, Allah t''a élue, t''a purifiée et t''a préférée aux femmes du monde.',
   'Sourate Aal-Imran (3:42)');

-- Q40 (difficile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le sens du terme islamique "Tawakkul" ?', 'difficile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La patience face aux épreuves (Sabr)',false,0),(q,'La gratitude envers Allah (Shukr)',false,1),(q,'La crainte révérencielle d''Allah (Taqwa)',false,2),(q,'La confiance et délégation totale à Allah',true,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Tawakkul consiste à prendre les moyens nécessaires puis à remettre le résultat entre les mains d''Allah, avec une confiance totale. Ce n''est pas la passivité mais la foi active.',
   'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ إِنَّ اللَّهَ بَالِغُ أَمْرِهِ',
   'Et quiconque place sa confiance en Allah, Il lui suffit. Certes Allah atteint Son commandement.',
   'Sourate At-Talaq (65:3)');

END $$;

-- ============================================================
-- SEED ADDITIONNEL — 300 Questions (lot 1a : facile piliers+coran)
-- ============================================================

-- Q41 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de rak''aat contient la prière du Fajr ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'1 rak''ah',false,0),(q,'2 rak''aat',true,1),(q,'3 rak''aat',false,2),(q,'4 rak''aat',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La prière du Fajr (aube) est composée de 2 rak''aat obligatoires. C''est la première prière de la journée.',
   'حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ وَقُومُوا لِلَّهِ قَانِتِينَ',
   'Observez scrupuleusement les prières — notamment la prière du milieu — et tenez-vous debout devant Allah avec piété.',
   'Sourate Al-Baqarah (2:238)');

-- Q42 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de rak''aat contient la prière du Dhuhr ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'2 rak''aat',false,0),(q,'3 rak''aat',false,1),(q,'4 rak''aat',true,2),(q,'5 rak''aat',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La prière du Dhuhr (milieu du jour) comporte 4 rak''aat obligatoires. Le Prophète ﷺ la priait lorsque le soleil commençait à décliner.',
   'أَقِمِ الصَّلَاةَ لِدُلُوكِ الشَّمْسِ إِلَىٰ غَسَقِ اللَّيْلِ وَقُرْآنَ الْفَجْرِ',
   'Accomplis la prière au déclin du soleil jusqu''à l''obscurité de la nuit, et [récite le] Coran à l''aube.',
   'Sourate Al-Isra (17:78)');

-- Q43 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de rak''aat contient la prière du Maghrib ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'2 rak''aat',false,0),(q,'3 rak''aat',true,1),(q,'4 rak''aat',false,2),(q,'5 rak''aat',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La prière du Maghrib (coucher du soleil) comporte 3 rak''aat. Elle est priée juste après le coucher du soleil.',
   'وَأَقِمِ الصَّلَاةَ طَرَفَيِ النَّهَارِ وَزُلَفًا مِّنَ اللَّيْلِ',
   'Accomplis la prière aux deux extrémités du jour et à certaines heures de la nuit.',
   'Sourate Hud (11:114)');

-- Q44 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Vers quelle direction les musulmans se tournent-ils pour prier ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Vers Jérusalem',false,0),(q,'Vers La Mecque (la Kaaba)',true,1),(q,'Vers Médine',false,2),(q,'Vers l''Est',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Qibla est la direction de la Kaaba à La Mecque. Tous les musulmans du monde entier se tournent vers elle lors de la prière.',
   'فَوَلِّ وَجْهَكَ شَطْرَ الْمَسْجِدِ الْحَرَامِ وَحَيْثُ مَا كُنتُمْ فَوَلُّوا وُجُوهَكُمْ شَطْرَهُ',
   'Tourne ton visage vers la Mosquée Sacrée. Et où que vous soyez, tournez vos visages vers elle.',
   'Sourate Al-Baqarah (2:144)');

-- Q45 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Comment s''appelle la purification rituelle accomplie avant la prière ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Ghusl',false,0),(q,'Tayammum',false,1),(q,'Wudhu (ablutions)',true,2),(q,'Istinja',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Wudhu est la purification rituelle obligatoire avant la prière. Il comprend le lavage du visage, des mains, le passage de la main sur la tête et le lavage des pieds.',
   'يَا أَيُّهَا الَّذِينَ آمَنُوا إِذَا قُمْتُمْ إِلَى الصَّلَاةِ فَاغْسِلُوا وُجُوهَكُمْ وَأَيْدِيَكُمْ',
   'Ô vous qui croyez ! Quand vous vous levez pour la prière, lavez vos visages et vos mains.',
   'Sourate Al-Ma''idah (5:6)');

-- Q46 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que l''Iftar ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le repas avant l''aube pendant le Ramadan',false,0),(q,'La rupture du jeûne au coucher du soleil',true,1),(q,'La prière de nuit',false,2),(q,'L''aumône de fin de Ramadan',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''Iftar est la rupture du jeûne au coucher du soleil. Le Prophète ﷺ recommandait de le hâter et de commencer par des dattes ou de l''eau.',
   'لَا يَزَالُ النَّاسُ بِخَيْرٍ مَا عَجَّلُوا الْفِطْرَ',
   'Les gens demeureront dans le bien tant qu''ils hâteront la rupture du jeûne.',
   'Sahih Bukhari — Hadith n°1957');

-- Q47 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Suhoor ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La prière surérogatoire de nuit',false,0),(q,'La rupture du jeûne',false,1),(q,'Le repas pris avant l''aube pendant le Ramadan',true,2),(q,'L''appel à la prière',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Suhoor est le repas pris avant l''aube pendant le Ramadan. Le Prophète ﷺ a dit qu''il y a une bénédiction dans ce repas.',
   'تَسَحَّرُوا فَإِنَّ فِي السَّحُورِ بَرَكَةً',
   'Prenez le repas de l''aube car il y a une bénédiction dans ce repas.',
   'Sahih Bukhari — Hadith n°1923');

-- Q48 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Le Hajj est obligatoire pour qui ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Tout musulman sans exception',false,0),(q,'Uniquement les hommes',false,1),(q,'Tout musulman capable (santé + finances)',true,2),(q,'Une fois tous les 5 ans pour chaque musulman',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Hajj est obligatoire une seule fois dans la vie pour tout musulman qui en a les capacités physiques et financières. C''est le cinquième pilier de l''Islam.',
   'وَلِلَّهِ عَلَى النَّاسِ حِجُّ الْبَيْتِ مَنِ اسْتَطَاعَ إِلَيْهِ سَبِيلًا',
   'C''est un devoir envers Allah pour les hommes de faire le pèlerinage de la Maison, pour celui qui peut y trouver un chemin.',
   'Sourate Aal-Imran (3:97)');

-- Q49 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Que signifie "Subhanallah" ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Allah est le plus grand',false,0),(q,'Gloire à Allah / Allah est parfait',true,1),(q,'Louange à Allah',false,2),(q,'Allah suffit',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'"Subhanallah" est une glorification d''Allah qui purge toute imperfection. Le Prophète ﷺ a dit que c''est l''une des phrases les plus aimées d''Allah.',
   'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ',
   'Gloire à Allah et Sa louange, Gloire à Allah l''Immense.',
   'Sahih Bukhari — Hadith n°6682');

-- Q50 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Que signifie "Alhamdulillah" ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Il n''y a de dieu qu''Allah',false,0),(q,'Gloire à Allah',false,1),(q,'Toute louange est à Allah',true,2),(q,'Allah est le plus grand',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'"Alhamdulillah" est une expression de gratitude et de louange à Allah. Le Prophète ﷺ a dit que cette formule remplit la balance.',
   'الْحَمْدُ لِلَّهِ تَمْلَأُ الْمِيزَانَ',
   '"Alhamdulillah" (Louange à Allah) remplit la balance.',
   'Sahih Muslim — Hadith n°223');

-- Q51 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Que signifie "Allahu Akbar" ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Louange à Allah',false,0),(q,'Allah est unique',false,1),(q,'Allah pardonne',false,2),(q,'Allah est le plus grand',true,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'"Allahu Akbar" est le Takbir, la proclamation de la grandeur d''Allah. C''est la première parole prononcée pour entrer en prière (Takbirat al-Ihram).',
   'اللَّهُ أَكْبَرُ كَبِيرًا وَالْحَمْدُ لِلَّهِ كَثِيرًا وَسُبْحَانَ اللَّهِ بُكْرَةً وَأَصِيلًا',
   'Allah est Immensément Grand, abondante est Sa louange, Gloire à Allah matin et soir.',
   'Sahih Muslim — Hadith n°601');

-- Q52 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Zakat ul-Fitr ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La Zakat annuelle sur la richesse',false,0),(q,'Une aumône volontaire',false,1),(q,'L''aumône obligatoire de fin de Ramadan',true,2),(q,'Le sacrifice de l''Aïd',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Zakat ul-Fitr est une aumône obligatoire versée avant la prière de l''Aïd al-Fitr. Elle purifie le jeûneur de ses fautes et nourrit les pauvres.',
   'فَرَضَ رَسُولُ اللَّهِ ﷺ زَكَاةَ الْفِطْرِ طُهْرَةً لِلصَّائِمِ مِنَ اللَّغْوِ وَالرَّفَثِ',
   'Le Messager d''Allah ﷺ a prescrit la Zakat al-Fitr comme purification pour le jeûneur des paroles vaines et obscènes.',
   'Sunan Abu Daoud — Hadith n°1609');

-- Q53 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Comment s''appelle la grande mosquée de La Mecque ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Al-Masjid An-Nabawi',false,0),(q,'Al-Masjid Al-Aqsa',false,1),(q,'Al-Masjid Al-Haram',true,2),(q,'Al-Masjid Al-Quba',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Al-Masjid Al-Haram est la plus grande mosquée du monde, située à La Mecque. Une prière y vaut 100 000 prières ailleurs.',
   'إِنَّ أَوَّلَ بَيْتٍ وُضِعَ لِلنَّاسِ لَلَّذِي بِبَكَّةَ مُبَارَكًا وَهُدًى لِّلْعَالَمِينَ',
   'La première Maison qui ait été édifiée pour les hommes est bien celle de Bakka (La Mecque), bénie et une direction pour les mondes.',
   'Sourate Aal-Imran (3:96)');

-- Q54 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom de la prière de la mi-journée ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Fajr',false,0),(q,'Dhuhr',true,1),(q,'Asr',false,2),(q,'Isha',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La prière du Dhuhr est priée quand le soleil commence à décliner après le zénith. Elle comporte 4 rak''aat.',
   'أَقِمِ الصَّلَاةَ لِدُلُوكِ الشَّمْسِ إِلَىٰ غَسَقِ اللَّيْلِ',
   'Accomplis la prière au déclin du soleil jusqu''à l''obscurité de la nuit.',
   'Sourate Al-Isra (17:78)');

-- Q55 (facile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom de la prière du soir accomplie après la disparition du rouge du ciel ?', 'facile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Maghrib',false,0),(q,'Isha',true,1),(q,'Tarawih',false,2),(q,'Witr',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La prière du Isha est la cinquième et dernière prière obligatoire de la journée. Elle comprend 4 rak''aat et est accomplie dans l''obscurité de la nuit.',
   'وَمِنْ آنَاءِ اللَّيْلِ فَسَبِّحْ وَأَطْرَافَ النَّهَارِ لَعَلَّكَ تَرْضَىٰ',
   'Et à certaines heures de la nuit, glorifie-Le, ainsi qu''aux extrémités du jour, peut-être seras-tu satisfait.',
   'Sourate Ta-Ha (20:130)');

-- Q56 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est la première sourate du Coran ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Al-Baqarah',false,0),(q,'Al-Fatiha',true,1),(q,'Al-Ikhlas',false,2),(q,'Al-Nas',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Al-Fatiha est la première sourate du Coran et l''ouverture de toute prière. Elle est aussi appelée "Umm al-Kitab" (la Mère du Livre).',
   'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
   'Au nom d''Allah, le Tout Miséricordieux, le Très Miséricordieux. Louange à Allah, Seigneur des mondes.',
   'Sourate Al-Fatiha (1:1-2)');

-- Q57 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est la dernière sourate du Coran ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Al-Ikhlas',false,0),(q,'Al-Falaq',false,1),(q,'An-Nas',true,2),(q,'Al-Masad',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'An-Nas est la 114ème et dernière sourate du Coran. Elle est une protection contre le mauvais œil et le murmure de Satan.',
   'قُلْ أَعُوذُ بِرَبِّ النَّاسِ مَلِكِ النَّاسِ إِلَٰهِ النَّاسِ',
   'Dis : Je cherche refuge auprès du Seigneur des hommes, le Roi des hommes, le Dieu des hommes.',
   'Sourate An-Nas (114:1-3)');

-- Q58 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de juz (parties) contient le Coran ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'20 juz',false,0),(q,'25 juz',false,1),(q,'28 juz',false,2),(q,'30 juz',true,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Coran est divisé en 30 juz (parties) de taille approximativement égale pour faciliter sa mémorisation et sa récitation quotidienne.',
   'إِنَّا نَحْنُ نَزَّلْنَا الذِّكْرَ وَإِنَّا لَهُ لَحَافِظُونَ',
   'C''est Nous qui avons fait descendre le Rappel, et c''est Nous qui en sommes les gardiens.',
   'Sourate Al-Hijr (15:9)');

-- Q59 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est la plus longue sourate du Coran ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Al-Imran',false,0),(q,'Al-Baqarah',true,1),(q,'An-Nisa',false,2),(q,'Al-A''raf',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Al-Baqarah est la plus longue sourate du Coran avec 286 versets. Le Prophète ﷺ a dit que sa récitation protège la maison de Satan.',
   'اقْرَؤُوا الزَّهْرَاوَيْنِ الْبَقَرَةَ وَسُورَةَ آلِ عِمْرَانَ فَإِنَّهُمَا تَأْتِيَانِ يَوْمَ الْقِيَامَةِ كَأَنَّهُمَا غَمَامَتَانِ',
   'Récitez les deux Zahraoui : Al-Baqarah et Aal-Imran, car elles viendront le Jour de la Résurrection comme deux nuages.',
   'Sahih Muslim — Hadith n°804');

-- Q60 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel ange a transmis la révélation du Coran au Prophète Muhammad ﷺ ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Mikail',false,0),(q,'Israfil',false,1),(q,'Jibril (Gabriel)',true,2),(q,'Azraïl',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'C''est Jibril (Gabriel) qui a transmis la révélation divine au Prophète ﷺ. C''est lui aussi qui est venu enseigner les piliers de l''Islam.',
   'قُلْ مَن كَانَ عَدُوًّا لِّجِبْرِيلَ فَإِنَّهُ نَزَّلَهُ عَلَىٰ قَلْبِكَ بِإِذْنِ اللَّهِ',
   'Dis : Quiconque est ennemi de Jibril... c''est lui qui l''a fait descendre sur ton cœur par la permission d''Allah.',
   'Sourate Al-Baqarah (2:97)');

-- Q61 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien d''années a duré la révélation du Coran en tout ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'10 ans',false,0),(q,'15 ans',false,1),(q,'23 ans',true,2),(q,'30 ans',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Coran a été révélé progressivement sur 23 ans : 13 ans à La Mecque et 10 ans à Médine. Cette révélation graduelle facilita sa compréhension et son application.',
   'وَقُرْآنًا فَرَقْنَاهُ لِتَقْرَأَهُ عَلَى النَّاسِ عَلَىٰ مُكْثٍ وَنَزَّلْنَاهُ تَنزِيلًا',
   'Et un Coran que Nous avons divisé pour que tu le lises aux hommes progressivement. Nous l''avons fait descendre graduellement.',
   'Sourate Al-Isra (17:106)');

-- Q62 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le verset du Coran appelé "Verset du Trône" (Ayat al-Kursi) ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Sourate Al-Fatiha 1:1',false,0),(q,'Sourate Al-Baqarah 2:255',true,1),(q,'Sourate Al-Ikhlas 112:1',false,2),(q,'Sourate Al-Hashr 59:22',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Ayat al-Kursi est le plus grand verset du Coran. Celui qui le récite après chaque prière n''a que le Paradis pour séparer de lui.',
   'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ',
   'Allah ! Point de divinité à part Lui, le Vivant, le Subsistant par Lui-même. Ni somnolence ni sommeil ne Le saisissent.',
   'Sourate Al-Baqarah (2:255)');

-- Q63 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de prophètes sont mentionnés par leur nom dans le Coran ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'10 prophètes',false,0),(q,'18 prophètes',false,1),(q,'25 prophètes',true,2),(q,'40 prophètes',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Coran mentionne 25 prophètes par leur nom. Parmi eux : Adam, Nuh, Ibrahim, Moussa, Issa et Muhammad ﷺ.',
   'وَرُسُلًا قَدْ قَصَصْنَاهُمْ عَلَيْكَ مِن قَبْلُ وَرُسُلًا لَّمْ نَقْصُصْهُمْ عَلَيْكَ',
   'Des messagers dont Nous t''avons déjà raconté l''histoire, et des messagers dont Nous ne t''avons pas raconté l''histoire.',
   'Sourate An-Nisa (4:164)');

-- Q64 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Que signifie le mot "Coran" en arabe ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le Livre sacré',false,0),(q,'La Parole d''Allah',false,1),(q,'La Récitation',true,2),(q,'Le Rappel',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le mot "Coran" vient de la racine arabe "qara''a" qui signifie lire ou réciter. La première révélation était "Iqra" (Lis/Récite).',
   'إِنَّ عَلَيْنَا جَمْعَهُ وَقُرْآنَهُ فَإِذَا قَرَأْنَاهُ فَاتَّبِعْ قُرْآنَهُ',
   'C''est à Nous d''en assurer la collecte et la récitation. Quand Nous le récitons, suis sa récitation.',
   'Sourate Al-Qiyamah (75:17-18)');

-- Q65 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est la sourate du Coran la plus courte (en nombre de versets) ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Al-Ikhlas (4 versets)',false,0),(q,'Al-Falaq (5 versets)',false,1),(q,'Al-Kawthar (3 versets)',true,2),(q,'Al-Asr (3 versets)',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Al-Kawthar est la plus courte sourate du Coran avec seulement 3 versets. Allah y promet une abondance de bien à Son Prophète ﷺ.',
   'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ فَصَلِّ لِرَبِّكَ وَانْحَرْ إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ',
   'Nous t''avons accordé Al-Kawthar. Prie donc pour ton Seigneur et sacrifie. Celui qui te hait sera privé de descendance.',
   'Sourate Al-Kawthar (108:1-3)');

-- Q66 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Dans quelle ville le Coran a-t-il commencé à être révélé ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Médine',false,0),(q,'Jérusalem',false,1),(q,'La Mecque',true,2),(q,'Taïf',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La première révélation du Coran eut lieu dans la grotte de Hira, près de La Mecque, en l''an 610 ap. J.-C. L''ange Jibril apparut au Prophète ﷺ et lui dit "Iqra" (Lis).',
   'اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ خَلَقَ الْإِنسَانَ مِنْ عَلَقٍ',
   'Lis au nom de ton Seigneur qui a créé, qui a créé l''homme d''une adhérence.',
   'Sourate Al-''Alaq (96:1-2)');

-- Q67 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle sourate est considérée comme le "cœur du Coran" ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Al-Fatiha',false,0),(q,'Al-Baqarah',false,1),(q,'Ya-Sin',true,2),(q,'Al-Mulk',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Prophète ﷺ a dit que Ya-Sin est le cœur du Coran. Celui qui la récite espérant la récompense d''Allah sera pardonné.',
   'يس وَالْقُرْآنِ الْحَكِيمِ إِنَّكَ لَمِنَ الْمُرْسَلِينَ',
   'Ya-Sin. Par le Coran plein de sagesse ! Tu es certes parmi les messagers.',
   'Sourate Ya-Sin (36:1-3)');

-- Q68 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle sourate recommande-t-on de réciter le vendredi ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Al-Mulk',false,0),(q,'Al-Kahf',true,1),(q,'Ya-Sin',false,2),(q,'Al-Waqiah',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Prophète ﷺ a recommandé de réciter la sourate Al-Kahf le vendredi. Elle protège de la fitna du Dajjal et illumine le chemin entre les deux vendredis.',
   'مَنْ قَرَأَ سُورَةَ الْكَهْفِ فِي يَوْمِ الْجُمُعَةِ أَضَاءَ لَهُ مِنَ النُّورِ مَا بَيْنَ الْجُمُعَتَيْنِ',
   'Celui qui récite la sourate Al-Kahf le vendredi sera illuminé d''une lumière entre les deux vendredis.',
   'Sunan Al-Bayhaqi — Hadith authentifié');

-- Q69 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle sourate contient entièrement l''histoire du prophète Yusuf (Joseph) ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Sourate Ibrahim',false,0),(q,'Sourate Yusuf (12)',true,1),(q,'Sourate Al-Anbiya',false,2),(q,'Sourate Al-Kahf',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La sourate Yusuf (12) est la seule sourate du Coran qui raconte l''histoire complète d''un prophète. Allah l''a appelée "la meilleure des histoires".',
   'نَحْنُ نَقُصُّ عَلَيْكَ أَحْسَنَ الْقَصَصِ بِمَا أَوْحَيْنَا إِلَيْكَ هَٰذَا الْقُرْآنَ',
   'Nous te racontons la meilleure des histoires en te révélant ce Coran.',
   'Sourate Yusuf (12:3)');

-- Q70 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Que signifie la formule "Bismillah ir-Rahman ir-Raheem" ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Gloire à Allah le Miséricordieux',false,0),(q,'Au nom d''Allah le Tout Miséricordieux le Très Miséricordieux',true,1),(q,'Louange à Allah le Généreux',false,2),(q,'Qu''Allah nous guide',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Basmala commence 113 des 114 sourates du Coran (sauf At-Tawbah). Le Prophète ﷺ recommandait de la dire avant toute chose importante.',
   'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
   'Au nom d''Allah, le Tout Miséricordieux, le Très Miséricordieux.',
   'Sourate Al-Fatiha (1:1)');

-- Q71 (facile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de versets (ayats) contient le Coran ?', 'facile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'5 000 versets',false,0),(q,'6 236 versets',true,1),(q,'7 000 versets',false,2),(q,'8 500 versets',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Coran contient 6 236 versets répartis en 114 sourates. Chaque verset est un signe (âya) d''Allah pour l''humanité.',
   'كِتَابٌ أَنزَلْنَاهُ إِلَيْكَ مُبَارَكٌ لِّيَدَّبَّرُوا آيَاتِهِ',
   'C''est un Livre béni que Nous t''avons révélé pour qu''ils méditent ses versets.',
   'Sourate Sad (38:29)');

-- Lot 1b : facile hadith + histoire + jurisprudence (Q72-Q110)

-- Q72 (facile / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce qu''un hadith ?', 'facile', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un chapitre du Coran',false,0),(q,'Un verset coranique',false,1),(q,'Les paroles, actes et approbations du Prophète ﷺ',true,2),(q,'Une prière surérogatoire',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Un hadith est une parole, un acte, une approbation tacite ou une description du Prophète ﷺ. Les hadiths constituent la Sunna et sont la deuxième source de l''Islam.',
   'وَمَا آتَاكُمُ الرَّسُولُ فَخُذُوهُ وَمَا نَهَاكُمْ عَنْهُ فَانتَهُوا',
   'Ce que le Messager vous donne, prenez-le ; et ce qu''il vous interdit, abstenez-vous-en.',
   'Sourate Al-Hashr (59:7)');

-- Q73 (facile / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le recueil de hadiths considéré le plus authentique après le Coran ?', 'facile', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Sunan Abu Daoud',false,0),(q,'Sahih Bukhari',true,1),(q,'Muwatta Malik',false,2),(q,'Musnad Ahmad',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Sahih Bukhari, compilé par l''imam Muhammad ibn Ismail al-Bukhari (m. 870), est considéré comme le recueil de hadiths le plus authentique. Il a sélectionné environ 7 275 hadiths parmi 600 000.',
   'أَصَحُّ كِتَابٍ بَعْدَ كِتَابِ اللَّهِ صَحِيحُ الْبُخَارِيِّ',
   'Le livre le plus authentique après le Livre d''Allah est le Sahih al-Bukhari.',
   'Parole des savants de l''Islam');

-- Q74 (facile / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Sunna ?', 'facile', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Les prières surérogatoires uniquement',false,0),(q,'La voie, pratique et exemple du Prophète ﷺ',true,1),(q,'Les versets coraniques révélés à Médine',false,2),(q,'Les lois islamiques écrites',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Sunna est la pratique du Prophète ﷺ : ses paroles, ses actes, ses approbations. Suivre la Sunna est une obligation pour tout musulman.',
   'لَّقَدْ كَانَ لَكُمْ فِي رَسُولِ اللَّهِ أُسْوَةٌ حَسَنَةٌ',
   'Vous avez dans le Messager d''Allah un excellent modèle.',
   'Sourate Al-Ahzab (33:21)');

-- Q75 (facile / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le hadith qui commence par "Les actes ne valent que par les intentions" ?', 'facile', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Hadith de Jibril',false,0),(q,'Hadith du Tawaf',false,1),(q,'Hadith des intentions (Niyyah)',true,2),(q,'Hadith des 5 piliers',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Ce hadith fondamental enseigne que la valeur de tout acte dépend de l''intention. Les savants le considèrent comme le tiers de l''Islam.',
   'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
   'Les actes ne valent que par les intentions, et chacun n''obtient que ce qu''il a voulu.',
   'Sahih Bukhari — Hadith n°1');

-- Q76 (facile / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qui est l''auteur du Sahih Muslim ?', 'facile', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'L''imam al-Bukhari',false,0),(q,'L''imam Muslim ibn al-Hajjaj',true,1),(q,'L''imam An-Nawawi',false,2),(q,'L''imam at-Tirmidhi',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''imam Muslim ibn al-Hajjaj (m. 875) a compilé le Sahih Muslim, deuxième recueil le plus authentique après Sahih Bukhari. Il contient environ 7 500 hadiths.',
   'وَمَا يَنطِقُ عَنِ الْهَوَىٰ إِنْ هُوَ إِلَّا وَحْيٌ يُوحَىٰ',
   'Il ne parle pas sous l''empire de la passion. Ce n''est rien d''autre qu''une révélation inspirée.',
   'Sourate An-Najm (53:3-4)');

-- Q77 (facile / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce qu''un Hadith Qudsi ?', 'facile', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un hadith très authentique',false,0),(q,'Un hadith narré par beaucoup de personnes',false,1),(q,'Une parole divine transmise par le Prophète ﷺ hors du Coran',true,2),(q,'Un hadith faible',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Hadith Qudsi est une parole dans laquelle Allah s''exprime à la première personne, transmise par le Prophète ﷺ, mais qui ne fait pas partie du Coran.',
   'يَقُولُ اللَّهُ تَعَالَى: أَنَا عِنْدَ ظَنِّ عَبْدِي بِي',
   'Allah dit : Je suis tel que Mon serviteur pense de Moi (j''exauce selon ses attentes).',
   'Sahih Bukhari — Hadith Qudsi n°7405');

-- Q78 (facile / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel hadith décrit les 3 niveaux de la religion : Islam, Iman et Ihsan ?', 'facile', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Hadith des intentions',false,0),(q,'Hadith de Jibril',true,1),(q,'Hadith des 5 piliers',false,2),(q,'Hadith de la miséricorde',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le hadith de Jibril est un hadith fondamental où l''ange Jibril vint interroger le Prophète ﷺ sur l''Islam, l''Iman et l''Ihsan devant les compagnons.',
   'الإِيمَانُ أَنْ تُؤْمِنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ وَالْيَوْمِ الْآخِرِ وَالْقَدَرِ',
   'L''Iman est de croire en Allah, Ses anges, Ses Livres, Ses messagers, au Jour Dernier et au destin.',
   'Sahih Muslim — Hadith n°8');

-- Q79 (facile / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de piliers de la foi (Iman) sont mentionnés dans le hadith de Jibril ?', 'facile', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'4 piliers',false,0),(q,'5 piliers',false,1),(q,'6 piliers',true,2),(q,'7 piliers',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les 6 piliers de l''Iman sont : croire en Allah, aux anges, aux Livres, aux prophètes, au Jour du Jugement, et au destin (bon et mauvais).',
   'آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ وَالْمُؤْمِنُونَ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ',
   'Le Messager croit en ce qui lui a été révélé par son Seigneur, et les croyants aussi. Ils croient tous en Allah, Ses anges, Ses Livres et Ses messagers.',
   'Sourate Al-Baqarah (2:285)');

-- Q80 (facile / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que l''Ihsan selon le hadith de Jibril ?', 'facile', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Accomplir les 5 piliers',false,0),(q,'Croire aux 6 piliers de la foi',false,1),(q,'Adorer Allah comme si tu Le voyais',true,2),(q,'Faire le Hajj au moins une fois',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''Ihsan est le plus haut niveau spirituel : adorer Allah avec une présence totale du cœur, comme si on Le voyait. Sinon, savoir qu''Il nous voit.',
   'الإِحْسَانُ أَنْ تَعْبُدَ اللَّهَ كَأَنَّكَ تَرَاهُ فَإِنْ لَمْ تَكُنْ تَرَاهُ فَإِنَّهُ يَرَاكَ',
   'L''Ihsan est d''adorer Allah comme si tu Le voyais ; si tu ne Le vois pas, sache qu''Il te voit.',
   'Sahih Muslim — Hadith n°8');

-- Q81 (facile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Dans quelle ville Muhammad ﷺ est-il né ?', 'facile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Médine',false,0),(q,'Jérusalem',false,1),(q,'La Mecque',true,2),(q,'Taïf',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Prophète Muhammad ﷺ est né à La Mecque en l''An de l''Éléphant (environ 570 ap. J.-C.), dans la tribu des Quraych, clan des Banu Hashim.',
   'وَمَا أَرْسَلْنَاكَ إِلَّا رَحْمَةً لِّلْعَالَمِينَ',
   'Nous ne t''avons envoyé qu''en miséricorde pour les mondes.',
   'Sourate Al-Anbiya (21:107)');

-- Q82 (facile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom du père du Prophète Muhammad ﷺ ?', 'facile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Abu Talib',false,0),(q,'Abdul-Muttalib',false,1),(q,'Abdullah',true,2),(q,'Hamza',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le père du Prophète ﷺ s''appelait Abdullah ibn Abdul-Muttalib. Il est décédé avant la naissance de son fils, laissant Muhammad ﷺ orphelin de père.',
   'أَلَمْ يَجِدْكَ يَتِيمًا فَآوَىٰ',
   'Ne t''a-t-Il pas trouvé orphelin et t''a-t-Il pas recueilli ?',
   'Sourate Ad-Duha (93:6)');

-- Q83 (facile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom de la première épouse du Prophète Muhammad ﷺ ?', 'facile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Aïcha',false,0),(q,'Khadijah bint Khuwaylid',true,1),(q,'Hafsah',false,2),(q,'Zaynab',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Khadijah fut la première épouse du Prophète ﷺ, la première à embrasser l''Islam et sa grande soutien. Elle mourut 3 ans avant la Hijra. Le Prophète ﷺ lui gardait un amour profond.',
   'فَضْلُ عَائِشَةَ عَلَى النِّسَاءِ كَفَضْلِ الثَّرِيدِ عَلَى سَائِرِ الطَّعَامِ',
   'La supériorité d''Aïcha sur les autres femmes est comme la supériorité du Tharid sur les autres nourritures.',
   'Sahih Bukhari — Hadith n°3770');

-- Q84 (facile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est la date de la Hijra (migration du Prophète ﷺ vers Médine) ?', 'facile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'610 ap. J.-C.',false,0),(q,'615 ap. J.-C.',false,1),(q,'622 ap. J.-C.',true,2),(q,'630 ap. J.-C.',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Hijra eut lieu en 622 ap. J.-C. et marque le début du calendrier islamique (Hégire). C''est un événement fondateur de la communauté musulmane.',
   'إِلَّا تَنصُرُوهُ فَقَدْ نَصَرَهُ اللَّهُ إِذْ أَخْرَجَهُ الَّذِينَ كَفَرُوا ثَانِيَ اثْنَيْنِ',
   'Si vous ne l''aidez pas, Allah l''a déjà aidé, quand les mécréants l''ont chassé — il était l''un des deux.',
   'Sourate At-Tawbah (9:40)');

-- Q85 (facile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom du premier calife de l''Islam ?', 'facile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Umar ibn al-Khattab',false,0),(q,'Ali ibn Abi Talib',false,1),(q,'Abu Bakr As-Siddiq',true,2),(q,'Uthman ibn Affan',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Abu Bakr As-Siddiq fut le premier calife après la mort du Prophète ﷺ. Il régna de 632 à 634 ap. J.-C. et fut le plus proche compagnon du Prophète ﷺ.',
   'لَوْ كُنتُ مُتَّخِذًا خَلِيلًا لَّاتَّخَذْتُ أَبَا بَكْرٍ خَلِيلًا',
   'Si je devais prendre un ami intime, j''aurais pris Abu Bakr comme ami intime.',
   'Sahih Bukhari — Hadith n°3656');

-- Q86 (facile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Dans quelle ville se trouve la mosquée Al-Aqsa ?', 'facile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La Mecque',false,0),(q,'Médine',false,1),(q,'Jérusalem (Al-Quds)',true,2),(q,'Le Caire',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Al-Masjid Al-Aqsa est la troisième mosquée la plus sainte en Islam, située à Jérusalem. C''est vers elle que les musulmans priaient avant le changement de Qibla.',
   'سُبْحَانَ الَّذِي أَسْرَىٰ بِعَبْدِهِ لَيْلًا مِّنَ الْمَسْجِدِ الْحَرَامِ إِلَى الْمَسْجِدِ الْأَقْصَى',
   'Gloire à Celui qui a fait voyager de nuit Son serviteur depuis la Mosquée Sacrée jusqu''à la Mosquée Al-Aqsa.',
   'Sourate Al-Isra (17:1)');

-- Q87 (facile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle grande bataille a marqué la première victoire des musulmans en l''an 2 de l''Hégire ?', 'facile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La bataille d''Uhud',false,0),(q,'La bataille de Badr',true,1),(q,'La bataille du Fossé',false,2),(q,'La conquête de La Mecque',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La bataille de Badr (624 ap. J.-C.) fut la première grande victoire des musulmans. 313 croyants vainquirent environ 1000 Quraychites. Allah envoya des anges en renfort.',
   'وَلَقَدْ نَصَرَكُمُ اللَّهُ بِبَدْرٍ وَأَنتُمْ أَذِلَّةٌ فَاتَّقُوا اللَّهَ لَعَلَّكُمْ تَشْكُرُونَ',
   'Allah vous a secourus à Badr alors que vous étiez faibles. Craignez donc Allah, peut-être serez-vous reconnaissants.',
   'Sourate Aal-Imran (3:123)');

-- Q88 (facile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien d''années a vécu le Prophète Muhammad ﷺ ?', 'facile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'55 ans',false,0),(q,'60 ans',false,1),(q,'63 ans',true,2),(q,'70 ans',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Prophète ﷺ vécut 63 ans. Il reçut la prophétie à 40 ans, passa 13 ans à La Mecque et 10 ans à Médine. Il s''éteignit le 12 Rabi al-Awwal de l''an 11 H.',
   'وَمَا مُحَمَّدٌ إِلَّا رَسُولٌ قَدْ خَلَتْ مِن قَبْلِهِ الرُّسُلُ',
   'Muhammad n''est qu''un messager — avant lui, des messagers sont déjà passés.',
   'Sourate Aal-Imran (3:144)');

-- Q89 (facile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom de la ville où le Prophète ﷺ a migré et où se trouve sa mosquée ?', 'facile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Taïf',false,0),(q,'Jérusalem',false,1),(q,'Médine (Al-Madinah Al-Munawwarah)',true,2),(q,'Hébron',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Médine, anciennement Yathrib, est la ville où le Prophète ﷺ a migré et où il est enterré. Al-Masjid An-Nabawi est la deuxième mosquée la plus sainte en Islam.',
   'صَلَاةٌ فِي مَسْجِدِي هَذَا خَيْرٌ مِنْ أَلْفِ صَلَاةٍ فِيمَا سِوَاهُ إِلَّا الْمَسْجِدَ الْحَرَامَ',
   'Une prière dans ma mosquée vaut mieux que mille prières ailleurs, sauf la Mosquée Sacrée.',
   'Sahih Bukhari — Hadith n°1190');

-- Q90 (facile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel calife était connu par le surnom "Al-Faruq" (celui qui distingue le vrai du faux) ?', 'facile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Abu Bakr As-Siddiq',false,0),(q,'Uthman ibn Affan',false,1),(q,'Ali ibn Abi Talib',false,2),(q,'Umar ibn al-Khattab',true,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Umar ibn al-Khattab reçut le surnom "Al-Faruq" car sa conversion à l''Islam distingua clairement les croyants des mécréants. Il est le deuxième calife (634-644 ap. J.-C.).',
   'يَا أَيُّهَا الَّذِينَ آمَنُوا إِن تَتَّقُوا اللَّهَ يَجْعَل لَّكُمْ فُرْقَانًا',
   'Ô vous qui croyez ! Si vous craignez Allah, Il vous accordera la faculté de distinguer [le vrai du faux].',
   'Sourate Al-Anfal (8:29)');

-- Q91 (facile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qui était Bilal ibn Rabah ?', 'facile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le scribe du Prophète ﷺ',false,0),(q,'Le premier muezzin de l''Islam',true,1),(q,'Le général des armées musulmanes',false,2),(q,'Le gouverneur de Médine',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Bilal ibn Rabah fut le premier muezzin de l''Islam. Ancien esclave d''Abyssinie, il fut affranchi par Abu Bakr après avoir été torturé pour sa foi. Sa voix magnifique appelait à la prière.',
   'يَا بِلَالُ قُمْ فَأَذِّنْ',
   'Ô Bilal, lève-toi et fais l''Adhan.',
   'Sahih Bukhari — Hadith n°604');

-- Q92 (facile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('En quelle année a eu lieu la conquête de La Mecque ?', 'facile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'2 AH (624 ap. J.-C.)',false,0),(q,'5 AH (627 ap. J.-C.)',false,1),(q,'8 AH (630 ap. J.-C.)',true,2),(q,'10 AH (632 ap. J.-C.)',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La conquête de La Mecque eut lieu en l''an 8 de l''Hégire (630 ap. J.-C.). Le Prophète ﷺ entra pacifiquement avec 10 000 hommes et proclama l''amnistie générale.',
   'إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ وَرَأَيْتَ النَّاسَ يَدْخُلُونَ فِي دِينِ اللَّهِ أَفْوَاجًا',
   'Quand vient le secours d''Allah et la victoire, et que tu vois les gens entrer en foule dans la religion d''Allah.',
   'Sourate An-Nasr (110:1-2)');

-- Q93 (facile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom de la première martyre de l''Islam ?', 'facile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Khadijah bint Khuwaylid',false,0),(q,'Aïcha bint Abi Bakr',false,1),(q,'Sumayyah bint Khayyat',true,2),(q,'Fatimah bint Muhammad',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Sumayyah bint Khayyat fut la première martyre de l''Islam, tuée par Abu Jahl pour avoir refusé d''abjurer sa foi. Le Prophète ﷺ lui promit le Paradis.',
   'إِنَّ الَّذِينَ آمَنُوا وَهَاجَرُوا وَجَاهَدُوا فِي سَبِيلِ اللَّهِ أُولَٰئِكَ يَرْجُونَ رَحْمَتَ اللَّهِ',
   'Ceux qui ont cru, émigré et lutté dans le chemin d''Allah espèrent la miséricorde d''Allah.',
   'Sourate Al-Baqarah (2:218)');

-- Q94 (facile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom de la fille du Prophète ﷺ qui est aussi la femme de Ali ibn Abi Talib ?', 'facile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Zaynab bint Muhammad',false,0),(q,'Ruqayyah bint Muhammad',false,1),(q,'Umm Kulthum bint Muhammad',false,2),(q,'Fatimah bint Muhammad',true,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Fatimah est la fille bien-aimée du Prophète ﷺ. Le Prophète ﷺ disait : "Fatimah est une partie de moi. Celui qui la met en colère me met en colère."',
   'فَاطِمَةُ بَضْعَةٌ مِنِّي فَمَنْ أَغْضَبَهَا أَغْضَبَنِي',
   'Fatimah est une partie de moi. Celui qui la met en colère me met en colère.',
   'Sahih Bukhari — Hadith n°3714');

-- Q95 (facile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom de l''uncle du Prophète ﷺ qui a défendu l''Islam lors de la bataille d''Uhud ?', 'facile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Abu Talib',false,0),(q,'Abbas ibn Abdul-Muttalib',false,1),(q,'Hamza ibn Abdul-Muttalib',true,2),(q,'Abu Lahab',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Hamza ibn Abdul-Muttalib, uncle du Prophète ﷺ et l''un des premiers musulmans, fut martyrisé lors de la bataille d''Uhud (625 ap. J.-C.). Le Prophète ﷺ l''appelait "le Lion d''Allah".',
   'وَلَا تَحْسَبَنَّ الَّذِينَ قُتِلُوا فِي سَبِيلِ اللَّهِ أَمْوَاتًا بَلْ أَحْيَاءٌ عِندَ رَبِّهِمْ',
   'Ne crois pas que ceux qui ont été tués dans le chemin d''Allah soient morts. Ils sont vivants auprès de leur Seigneur.',
   'Sourate Aal-Imran (3:169)');

-- Q96 (facile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Que signifie le terme "Halal" ?', 'facile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Interdit par la loi islamique',false,0),(q,'Ce qui est permis et licite en Islam',true,1),(q,'Obligatoire en Islam',false,2),(q,'Fortement recommandé',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'"Halal" signifie ce qui est permis et licite par la loi islamique (Sharia). Son opposé est "Haram" (interdit). Allah a rendu halal ce qui est bon pour l''humanité.',
   'يَا أَيُّهَا النَّاسُ كُلُوا مِمَّا فِي الْأَرْضِ حَلَالًا طَيِّبًا',
   'Ô hommes ! Mangez de ce qui est licite et bon sur la terre.',
   'Sourate Al-Baqarah (2:168)');

-- Q97 (facile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('La consommation de viande de porc est-elle permise en Islam ?', 'facile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Oui, si elle est bien cuite',false,0),(q,'Oui, dans certains pays',false,1),(q,'Non, elle est formellement interdite (Haram)',true,2),(q,'Seulement interdite aux imams',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La viande de porc est explicitement interdite dans le Coran. Cette interdiction est absolue et ne souffre d''exceptions qu''en cas de nécessité vitale extrême.',
   'إِنَّمَا حَرَّمَ عَلَيْكُمُ الْمَيْتَةَ وَالدَّمَ وَلَحْمَ الْخِنزِيرِ وَمَا أُهِلَّ بِهِ لِغَيْرِ اللَّهِ',
   'Il vous a seulement interdit la bête morte, le sang, la viande de porc et ce sur quoi on a invoqué un autre qu''Allah.',
   'Sourate Al-Baqarah (2:173)');

-- Q98 (facile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('La consommation d''alcool est-elle permise en Islam ?', 'facile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Oui, en petite quantité',false,0),(q,'Seulement lors des fêtes',false,1),(q,'Non, l''alcool est formellement interdit (Haram)',true,2),(q,'C''est déconseillé mais pas interdit',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''alcool est interdit en Islam. L''interdiction fut révélée progressivement et confirmée définitivement dans la sourate Al-Ma''idah.',
   'يَا أَيُّهَا الَّذِينَ آمَنُوا إِنَّمَا الْخَمْرُ وَالْمَيْسِرُ وَالْأَنصَابُ وَالْأَزْلَامُ رِجْسٌ مِّنْ عَمَلِ الشَّيْطَانِ',
   'Ô croyants ! Le vin, le jeu de hasard, les idoles et les flèches divinatoires ne sont qu''une abomination, œuvre du Diable.',
   'Sourate Al-Ma''idah (5:90)');

-- Q99 (facile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Nikah en Islam ?', 'facile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le divorce islamique',false,0),(q,'Le pèlerinage mineur',false,1),(q,'Le contrat de mariage islamique',true,2),(q,'L''héritage islamique',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Nikah est le contrat de mariage islamique, un acte d''adoration. Elle nécessite le consentement des deux parties, un tuteur (wali), deux témoins et une dot (mahr).',
   'وَمِنْ آيَاتِهِ أَنْ خَلَقَ لَكُم مِّنْ أَنفُسِكُمْ أَزْوَاجًا لِّتَسْكُنُوا إِلَيْهَا وَجَعَلَ بَيْنَكُم مَّوَدَّةً وَرَحْمَةً',
   'Parmi Ses signes, Il a créé pour vous des épouses tirées de vous-mêmes pour que vous trouviez en elles la quiétude. Il a mis entre vous l''amour et la tendresse.',
   'Sourate Ar-Rum (30:21)');

-- Q100 (facile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Mahr (dot) en Islam ?', 'facile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La somme payée par la famille de la mariée',false,0),(q,'Le don obligatoire offert par le mari à sa femme lors du mariage',true,1),(q,'Le repas du mariage',false,2),(q,'Le cadeau offert aux invités',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Mahr (ou Sadaq) est un don obligatoire que l''époux remet à son épouse lors du contrat de mariage. C''est son droit exclusif.',
   'وَآتُوا النِّسَاءَ صَدُقَاتِهِنَّ نِحْلَةً',
   'Donnez aux femmes leur dot de bon gré.',
   'Sourate An-Nisa (4:4)');

-- Q101 (facile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de témoins sont requis pour valider un mariage islamique ?', 'facile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'1 témoin',false,0),(q,'2 témoins',true,1),(q,'3 témoins',false,2),(q,'4 témoins',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le mariage islamique nécessite 2 témoins musulmans adultes pour être valide. Le mariage secret sans témoins est invalide selon le consensus des savants.',
   'لَا نِكَاحَ إِلَّا بِوَلِيٍّ وَشَاهِدَيْ عَدْلٍ',
   'Pas de mariage sans tuteur et deux témoins équitables.',
   'Rapporté par Al-Bayhaqi — Classifié Sahih');

-- Q102 (facile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Ghusul ?', 'facile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'L''ablution partielle avant la prière',false,0),(q,'Le bain rituel de purification complète',true,1),(q,'La prière de l''aube',false,2),(q,'Le sacrifice lors de l''Aïd',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Ghusul est la purification corporelle complète (bain rituel) obligatoire dans certains cas : après des rapports conjugaux, après la menstruation, après les lochies, et avant le vendredi.',
   'وَإِن كُنتُمْ جُنُبًا فَاطَّهَّرُوا',
   'Et si vous êtes en état d''impureté majeure, purifiez-vous.',
   'Sourate Al-Ma''idah (5:6)');

-- Q103 (facile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Riba en Islam ?', 'facile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La charité volontaire',false,0),(q,'L''intérêt/usure interdit en Islam',true,1),(q,'Le commerce international',false,2),(q,'La spéculation boursière uniquement',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Riba (intérêt/usure) est formellement interdit en Islam. Allah a déclaré la guerre à celui qui pratique le Riba. C''est l''un des sept péchés majeurs.',
   'وَأَحَلَّ اللَّهُ الْبَيْعَ وَحَرَّمَ الرِّبَا',
   'Allah a rendu licite le commerce et illicite l''usure.',
   'Sourate Al-Baqarah (2:275)');

-- Q104 (facile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que l''Istikhara ?', 'facile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La prière du vendredi',false,0),(q,'La prière de demande de guidance divine avant une décision',true,1),(q,'La prière des funérailles',false,2),(q,'La prière du voyage',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''Istikhara est une prière de 2 rak''aat suivie d''une supplication spécifique, accomplie lorsqu''on doit prendre une décision importante. Le Prophète ﷺ l''enseignait à ses compagnons.',
   'كَانَ النَّبِيُّ ﷺ يُعَلِّمُنَا الاسْتِخَارَةَ فِي الأُمُورِ كُلِّهَا',
   'Le Prophète ﷺ nous enseignait l''Istikhara pour toutes les affaires.',
   'Sahih Bukhari — Hadith n°1166');

-- Q105 (facile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Waqf en Islam ?', 'facile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le testament islamique',false,0),(q,'La dot du mariage',false,1),(q,'La fondation pieuse — bien légué à des fins charitables permanentes',true,2),(q,'La taxe sur les non-musulmans',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Waqf est un bien immobilisé de façon permanente pour une cause charitable. Ses revenus bénéficient perpétuellement à la communauté. C''est une Sadaqa Jariya (aumône continue).',
   'إِذَا مَاتَ الإِنْسَانُ انْقَطَعَ عَنْهُ عَمَلُهُ إِلَّا مِنْ ثَلَاثَةٍ: صَدَقَةٍ جَارِيَةٍ',
   'Quand l''homme meurt, ses actes s''arrêtent sauf trois : une aumône continue (Sadaqa Jariya).',
   'Sahih Muslim — Hadith n°1631');

-- Q106 (facile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Talaq en Islam ?', 'facile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le mariage islamique',false,0),(q,'La dot de la mariée',false,1),(q,'Le divorce islamique initié par l''époux',true,2),(q,'L''héritage islamique',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Talaq est le divorce islamique par lequel un mari peut mettre fin au mariage. C''est l''acte licite le plus détesté d''Allah. Il doit être évité autant que possible.',
   'أَبْغَضُ الْحَلَالِ إِلَى اللَّهِ الطَّلَاقُ',
   'L''acte licite le plus détesté d''Allah est le divorce.',
   'Sunan Abu Daoud — Hadith n°2178');

-- Q107 (facile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Sadaqa ?', 'facile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La Zakat obligatoire annuelle',false,0),(q,'L''aumône volontaire en Islam',true,1),(q,'Le jeûne du Ramadan',false,2),(q,'La prière surérogatoire',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Sadaqa est l''aumône volontaire. Elle peut être financière, mais aussi un sourire, une parole gentille ou une aide. Elle éteint les péchés comme l''eau éteint le feu.',
   'مَثَلُ الَّذِينَ يُنفِقُونَ أَمْوَالَهُمْ فِي سَبِيلِ اللَّهِ كَمَثَلِ حَبَّةٍ أَنبَتَتْ سَبْعَ سَنَابِلَ',
   'Ceux qui dépensent leurs biens dans le chemin d''Allah ressemblent à un grain qui fait pousser sept épis.',
   'Sourate Al-Baqarah (2:261)');

-- Q108 (facile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Fidya dans le cadre du Ramadan ?', 'facile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un jeûne de rattrapage',false,0),(q,'Une compensation financière pour incapacité permanente à jeûner',true,1),(q,'Un sacrifice animal',false,2),(q,'Une prière supplémentaire',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Fidya est une compensation financière (nourrir un pauvre par jour de jeûne manqué) pour ceux qui ne peuvent définitivement pas jeûner : personnes âgées, malades chroniques.',
   'وَعَلَى الَّذِينَ يُطِيقُونَهُ فِدْيَةٌ طَعَامُ مِسْكِينٍ',
   'Et pour ceux qui ne peuvent le supporter qu''avec grande peine, une compensation : nourrir un pauvre.',
   'Sourate Al-Baqarah (2:184)');

-- Q109 (facile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Qurbani (Udhiya) ?', 'facile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le jeûne du Dhul-Hijja',false,0),(q,'Le sacrifice animal lors de l''Aïd al-Adha',true,1),(q,'La prière de l''Aïd',false,2),(q,'L''aumône de l''Aïd',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Qurbani est le sacrifice d''un animal (mouton, chèvre, vache ou chameau) lors de l''Aïd al-Adha en commémoration du sacrifice d''Ibrahim. La viande est partagée en trois parties.',
   'فَصَلِّ لِرَبِّكَ وَانْحَرْ',
   'Prie donc pour ton Seigneur et sacrifie.',
   'Sourate Al-Kawthar (108:2)');

-- Q110 (facile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le statut du mensonge en Islam ?', 'facile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Permis (Mubah)',false,0),(q,'Déconseillé (Makruh)',false,1),(q,'Interdit (Haram) sauf cas très spécifiques',true,2),(q,'Obligatoire dans certaines situations',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le mensonge est interdit en Islam. Le Prophète ﷺ a dit qu''il mène au péché et le péché mène au Feu. La vérité est une obligation du croyant.',
   'عَلَيْكُمْ بِالصِّدْقِ فَإِنَّ الصِّدْقَ يَهْدِي إِلَى الْبِرِّ وَإِنَّ الْبِرَّ يَهْدِي إِلَى الْجَنَّةِ',
   'Tenez-vous à la vérité car elle mène à la vertu, et la vertu mène au Paradis.',
   'Sahih Bukhari — Hadith n°6094');

-- Lot 1c : facile prophetes + foi (Q111-Q140)

-- Q111 (facile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qui est le père de tous les prophètes ?', 'facile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Adam',false,0),(q,'Nuh (Noé)',false,1),(q,'Ibrahim (Abraham)',true,2),(q,'Moussa (Moïse)',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Ibrahim est appelé "Abul-Anbiya" (père des prophètes) car de nombreux prophètes descended de lui : Ismaïl, Ishaq, Ya''qub, Yusuf, Moussa, Issa et Muhammad ﷺ.',
   'مِلَّةَ أَبِيكُمْ إِبْرَاهِيمَ هُوَ سَمَّاكُمُ الْمُسْلِمِينَ',
   'La religion de votre père Ibrahim, c''est lui qui vous a nommés "Musulmans".',
   'Sourate Al-Hajj (22:78)');

-- Q112 (facile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète est connu pour avoir survécu dans le ventre d''une baleine ?', 'facile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Nuh (Noé)',false,0),(q,'Yunus (Jonas)',true,1),(q,'Ayyub (Job)',false,2),(q,'Ibrahim (Abraham)',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le prophète Yunus (Jonas) fut avalé par une grande baleine après avoir quitté son peuple sans permission. Il invoqua Allah dans les ténèbres et fut sauvé.',
   'فَنَادَىٰ فِي الظُّلُمَاتِ أَن لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
   'Il invoqua dans les ténèbres : Il n''y a de dieu que Toi, Gloire à Toi, j''ai été du nombre des injustes.',
   'Sourate Al-Anbiya (21:87)');

-- Q113 (facile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète a reçu la Torah (Tawrat) ?', 'facile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Ibrahim (Abraham)',false,0),(q,'Daoud (David)',false,1),(q,'Issa (Jésus)',false,2),(q,'Moussa (Moïse)',true,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Allah a révélé la Torah à Moussa (Moïse). C''est l''un des livres divins mentionnés dans le Coran, avant qu''il soit altéré.',
   'إِنَّا أَنزَلْنَا التَّوْرَاةَ فِيهَا هُدًى وَنُورٌ',
   'Nous avons fait descendre la Torah dans laquelle se trouvent une direction et une lumière.',
   'Sourate Al-Ma''idah (5:44)');

-- Q114 (facile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète a reçu l''Injil (Évangile) ?', 'facile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Yahya (Jean-Baptiste)',false,0),(q,'Zakariyya (Zacharie)',false,1),(q,'Ibrahim (Abraham)',false,2),(q,'Issa (Jésus)',true,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''Injil a été révélé à Issa (Jésus). Selon l''Islam, l''Évangile original était la parole d''Allah, mais il a été altéré au fil du temps.',
   'وَآتَيْنَاهُ الْإِنجِيلَ فِيهِ هُدًى وَنُورٌ',
   'Nous lui avons donné l''Évangile, dans lequel il y a une direction et une lumière.',
   'Sourate Al-Ma''idah (5:46)');

-- Q115 (facile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète a construit l''arche pour sauver les croyants du déluge ?', 'facile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Ibrahim (Abraham)',false,0),(q,'Idris (Énoch)',false,1),(q,'Nuh (Noé)',true,2),(q,'Hud',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Nuh (Noé) construisit l''arche sur ordre d''Allah pour sauver les croyants et les animaux du déluge. Il prêcha son peuple pendant 950 ans.',
   'وَلَقَدْ أَرْسَلْنَا نُوحًا إِلَىٰ قَوْمِهِ فَلَبِثَ فِيهِمْ أَلْفَ سَنَةٍ إِلَّا خَمْسِينَ عَامًا',
   'Nous avons envoyé Nuh à son peuple. Il demeura parmi eux mille ans moins cinquante.',
   'Sourate Al-Ankabut (29:14)');

-- Q116 (facile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète est connu pour sa patience extraordinaire face aux épreuves ?', 'facile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Yunus (Jonas)',false,0),(q,'Ayyub (Job)',true,1),(q,'Ibrahim (Abraham)',false,2),(q,'Yaqub (Jacob)',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Ayyub (Job) fut éprouvé par Allah avec des maladies graves et des pertes. Il fit preuve d''une patience exemplaire et invoqua Allah, qui le guérit et lui rendit tout ce qu''il avait perdu.',
   'وَأَيُّوبَ إِذْ نَادَىٰ رَبَّهُ أَنِّي مَسَّنِيَ الضُّرُّ وَأَنتَ أَرْحَمُ الرَّاحِمِينَ',
   'Et Ayyub quand il appela son Seigneur : l''adversité m''a touché et Tu es le plus Miséricordieux des miséricordieux.',
   'Sourate Al-Anbiya (21:83)');

-- Q117 (facile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le premier prophète envoyé par Allah selon l''Islam ?', 'facile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Ibrahim (Abraham)',false,0),(q,'Nuh (Noé)',false,1),(q,'Idris (Énoch)',false,2),(q,'Adam',true,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Adam est le premier homme et le premier prophète. Allah le créa de ses propres mains, lui insuffla Son esprit et l''installa dans le Paradis avant de l''envoyer sur Terre.',
   'إِنَّ مَثَلَ عِيسَىٰ عِندَ اللَّهِ كَمَثَلِ آدَمَ خَلَقَهُ مِن تُرَابٍ',
   'Le cas de Issa auprès d''Allah est comparable à celui d''Adam qu''Il créa de poussière.',
   'Sourate Aal-Imran (3:59)');

-- Q118 (facile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète a été jeté dans le feu par son peuple mais n''a pas brûlé ?', 'facile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Moussa (Moïse)',false,0),(q,'Yusuf (Joseph)',false,1),(q,'Ibrahim (Abraham)',true,2),(q,'Ismail',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Ibrahim brisa les idoles de son peuple et fut condamné au bûcher. Allah ordonna au feu d''être frais et paisible pour Ibrahim. C''est un miracle attesté dans le Coran.',
   'قُلْنَا يَا نَارُ كُونِي بَرْدًا وَسَلَامًا عَلَىٰ إِبْرَاهِيمَ',
   'Nous dîmes : Ô feu, sois frais et paisible pour Ibrahim.',
   'Sourate Al-Anbiya (21:69)');

-- Q119 (facile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète a reçu le Zabur (Psaumes) ?', 'facile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Moussa (Moïse)',false,0),(q,'Sulayman (Salomon)',false,1),(q,'Daoud (David)',true,2),(q,'Ibrahim (Abraham)',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Allah a révélé le Zabur (Psaumes) à Daoud (David). Daoud était doté d''une voix magnifique et récitait les louanges d''Allah, et même les montagnes et les oiseaux se joignaient à lui.',
   'وَلَقَدْ آتَيْنَا دَاوُودَ مِنَّا فَضْلًا يَا جِبَالُ أَوِّبِي مَعَهُ وَالطَّيْرَ',
   'Nous avons accordé à Daoud une faveur de Notre part : Ô montagnes, répétez avec lui [les louanges] ! Et les oiseaux aussi.',
   'Sourate Saba (34:10)');

-- Q120 (facile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète est fils de Maryam (Marie) selon le Coran ?', 'facile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Yahya (Jean-Baptiste)',false,0),(q,'Ibrahim (Abraham)',false,1),(q,'Zakariyya (Zacharie)',false,2),(q,'Issa (Jésus)',true,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Issa (Jésus), fils de Maryam, est l''un des grands prophètes de l''Islam. Il est né miraculeusement sans père et accomplira de nombreux miracles avec la permission d''Allah.',
   'إِنَّمَا الْمَسِيحُ عِيسَى ابْنُ مَرْيَمَ رَسُولُ اللَّهِ وَكَلِمَتُهُ أَلْقَاهَا إِلَىٰ مَرْيَمَ وَرُوحٌ مِّنْهُ',
   'Le Messie Issa, fils de Maryam, est seulement le Messager d''Allah, Sa parole qu''Il projeta en Maryam, et un Esprit venant de Lui.',
   'Sourate An-Nisa (4:171)');

-- Q121 (facile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète a fendu la mer pour laisser passer son peuple ?', 'facile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Ibrahim (Abraham)',false,0),(q,'Nuh (Noé)',false,1),(q,'Moussa (Moïse)',true,2),(q,'Sulayman (Salomon)',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Moussa (Moïse) frappa la mer avec son bâton sur ordre d''Allah, qui se fendit en 12 chemins secs. Les Bani Israïl purent traverser tandis que Pharaon et son armée furent noyés.',
   'فَأَوْحَيْنَا إِلَىٰ مُوسَىٰ أَنِ اضْرِب بِّعَصَاكَ الْبَحْرَ فَانفَلَقَ فَكَانَ كُلُّ فِرْقٍ كَالطَّوْدِ الْعَظِيمِ',
   'Nous inspirâmes à Moussa de frapper la mer avec son bâton. Elle se fendit et chaque partie était comme une grande montagne.',
   'Sourate Ash-Shu''ara (26:63)');

-- Q122 (facile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète avait été vendu par ses frères comme esclave et devint grand d''Égypte ?', 'facile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Ismail',false,0),(q,'Yusuf (Joseph)',true,1),(q,'Ishaq (Isaac)',false,2),(q,'Ya''qub (Jacob)',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Yusuf (Joseph) fut jeté dans un puits par ses frères jaloux, puis vendu comme esclave en Égypte. Grâce à sa foi et sa patience, il devint ministre du roi.',
   'قَالَ لَا تَثْرِيبَ عَلَيْكُمُ الْيَوْمَ يَغْفِرُ اللَّهُ لَكُمْ وَهُوَ أَرْحَمُ الرَّاحِمِينَ',
   'Il dit : Pas de reproche contre vous aujourd''hui. Qu''Allah vous pardonne ! Il est le plus Miséricordieux des miséricordieux.',
   'Sourate Yusuf (12:92)');

-- Q123 (facile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète est connu pour commander le vent et les djinns ?', 'facile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Daoud (David)',false,0),(q,'Sulayman (Salomon)',true,1),(q,'Moussa (Moïse)',false,2),(q,'Ibrahim (Abraham)',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Sulayman (Salomon) reçut d''Allah le commandement des djinns, des hommes, des animaux et du vent. Il comprenait le langage des oiseaux et dirigeait un vaste royaume.',
   'وَلِسُلَيْمَانَ الرِّيحَ عَاصِفَةً تَجْرِي بِأَمْرِهِ',
   'Et pour Sulayman, le vent violent qui soufflait selon son commandement.',
   'Sourate Al-Anbiya (81)');

-- Q124 (facile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qui est le père du prophète Issa (Jésus) selon l''Islam ?', 'facile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Zakariyya',false,0),(q,'Yahya',false,1),(q,'Yusuf le charpentier',false,2),(q,'Issa n''a pas de père — naissance miraculeuse',true,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Selon le Coran, Issa (Jésus) est né d''une mère vierge (Maryam) sans père. Allah dit à ce sujet "Sois" et il fut. C''est un miracle divin.',
   'قَالَتْ رَبِّ أَنَّىٰ يَكُونُ لِي وَلَدٌ وَلَمْ يَمْسَسْنِي بَشَرٌ قَالَ كَذَٰلِكِ اللَّهُ يَخْلُقُ مَا يَشَاءُ',
   'Elle dit : Mon Seigneur, comment aurai-je un enfant, puisqu''aucun homme ne m''a touchée ? Il dit : Ainsi, Allah crée ce qu''Il veut.',
   'Sourate Aal-Imran (3:47)');

-- Q125 (facile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète est connu pour avoir entendu Allah lui parler directement ?', 'facile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Ibrahim (Abraham)',false,0),(q,'Daoud (David)',false,1),(q,'Moussa (Moïse)',true,2),(q,'Issa (Jésus)',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Moussa est appelé "Kalimullah" (Celui à qui Allah a parlé directement). Allah lui parla lors de l''épisode du Buisson ardent et sur le Mont Sinaï.',
   'وَكَلَّمَ اللَّهُ مُوسَىٰ تَكْلِيمًا',
   'Allah a parlé à Moussa directement.',
   'Sourate An-Nisa (4:164)');

-- Q126 (facile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de piliers de la foi (Arkan al-Iman) y a-t-il en Islam ?', 'facile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'4 piliers',false,0),(q,'5 piliers',false,1),(q,'6 piliers',true,2),(q,'8 piliers',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les 6 piliers de l''Iman : croire en Allah, aux anges, aux Livres, aux prophètes, au Jour du Jugement, et au destin (bon et mauvais). Ces 6 piliers sont mentionnés dans le hadith de Jibril.',
   'آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ وَالْمُؤْمِنُونَ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ',
   'Le Messager croit en ce qui lui a été révélé par son Seigneur, et les croyants aussi croient en Allah, Ses anges, Ses Livres et Ses messagers.',
   'Sourate Al-Baqarah (2:285)');

-- Q127 (facile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Tawhid ?', 'facile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La prière obligatoire',false,0),(q,'L''unicité absolue d''Allah',true,1),(q,'Le pilier du jeûne',false,2),(q,'La foi aux anges',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Tawhid est le fondement de l''Islam : croire qu''Allah est Un, unique, sans associé ni partenaire. C''est le message de tous les prophètes.',
   'قُلْ هُوَ اللَّهُ أَحَدٌ اللَّهُ الصَّمَدُ لَمْ يَلِدْ وَلَمْ يُولَدْ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
   'Dis : Il est Allah, Un. Allah, l''Absolu. Il n''a pas engendré et n''a pas été engendré. Et nul n''est égal à Lui.',
   'Sourate Al-Ikhlas (112:1-4)');

-- Q128 (facile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Shirk ?', 'facile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le jeûne du lundi et jeudi',false,0),(q,'Une forme de prière',false,1),(q,'Associer des partenaires à Allah — le plus grand péché',true,2),(q,'Le doute dans la foi',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Shirk est l''associationnisme — attribuer des partenaires, des égaux ou des fils à Allah. C''est le seul péché qu''Allah ne pardonnera pas si on meurt sans en être repentant.',
   'إِنَّ اللَّهَ لَا يَغْفِرُ أَن يُشْرَكَ بِهِ وَيَغْفِرُ مَا دُونَ ذَٰلِكَ لِمَن يَشَاءُ',
   'Allah ne pardonne pas qu''on Lui associe des partenaires ; mais Il pardonne ce qui est moindre à qui Il veut.',
   'Sourate An-Nisa (4:48)');

-- Q129 (facile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Janna ?', 'facile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'L''Enfer en Islam',false,0),(q,'Le Purgatoire',false,1),(q,'Le Paradis en Islam',true,2),(q,'La Résurrection',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Janna (Paradis) est la récompense éternelle des croyants pieux. Il contient ce qu''aucun œil n''a vu, aucune oreille n''a entendu et aucun cœur humain n''a imaginé.',
   'فَلَا تَعْلَمُ نَفْسٌ مَّا أُخْفِيَ لَهُم مِّن قُرَّةِ أَعْيُنٍ جَزَاءً بِمَا كَانُوا يَعْمَلُونَ',
   'Nulle âme ne sait ce qui lui est caché comme bonheur des yeux, en récompense de ce qu''elle accomplissait.',
   'Sourate As-Sajdah (32:17)');

-- Q130 (facile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Jahannam ?', 'facile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le Paradis en Islam',false,0),(q,'L''état intermédiaire après la mort',false,1),(q,'L''Enfer en Islam',true,2),(q,'Le Jour du Jugement',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Jahannam est l''Enfer, la punition éternelle des mécréants et des pécheurs endarcis. Le Coran en décrit les châtiments pour dissuader les croyants du péché.',
   'إِنَّ جَهَنَّمَ كَانَتْ مِرْصَادًا لِّلطَّاغِينَ مَآبًا',
   'Certes la Géhenne est un lieu d''aguet, un refuge pour les transgresseurs.',
   'Sourate An-Naba (78:21-22)');

-- Q131 (facile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que l''Akhirah ?', 'facile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La vie présente (Dunya)',false,0),(q,'La vie après la mort — le monde de l''Au-delà',true,1),(q,'Le Paradis uniquement',false,2),(q,'La nuit du destin',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''Akhirah désigne la vie après la mort dans son ensemble : le Barzakh (tombe), la Résurrection, le Jugement, et finalement le Paradis ou l''Enfer.',
   'وَمَا الْحَيَاةُ الدُّنْيَا إِلَّا لَعِبٌ وَلَهْوٌ وَلَلدَّارُ الْآخِرَةُ خَيْرٌ لِّلَّذِينَ يَتَّقُونَ',
   'La vie d''ici-bas n''est que jeu et divertissement. La Demeure de l''Au-delà est meilleure pour ceux qui craignent Allah.',
   'Sourate Al-An''am (6:32)');

-- Q132 (facile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Croire aux anges (Mala''ika) est-il un pilier de la foi en Islam ?', 'facile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Non, c''est facultatif',false,0),(q,'Seulement pour les savants',false,1),(q,'Oui, c''est le deuxième pilier de la foi',true,2),(q,'Oui, mais seulement Jibril et Mikail',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Croire aux anges est le deuxième pilier de la foi. Les anges sont des créatures de lumière, serviteurs d''Allah, qui n''ont pas de libre-arbitre et obéissent parfaitement à Allah.',
   'وَلَا تَقُولُوا لِمَنْ يُقْتَلُ فِي سَبِيلِ اللَّهِ أَمْوَاتٌ بَلْ أَحْيَاءٌ',
   'Et n''appelez pas morts ceux qui sont tués dans le chemin d''Allah. Ils sont vivants.',
   'Sourate Al-Baqarah (2:154)');

-- Q133 (facile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Tawbah (repentir) en Islam ?', 'facile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Une prière spéciale',false,0),(q,'Le retour sincère vers Allah après un péché',true,1),(q,'Le jeûne expiatoire',false,2),(q,'La récitation du Coran',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Tawbah est le repentir sincère : regretter le péché, l''abandonner, décider de ne pas recommencer et réparer le préjudice causé si possible. Allah aime celui qui se repent.',
   'إِنَّ اللَّهَ يُحِبُّ التَّوَّابِينَ وَيُحِبُّ الْمُتَطَهِّرِينَ',
   'Allah aime ceux qui se repentent et aime ceux qui se purifient.',
   'Sourate Al-Baqarah (2:222)');

-- Q134 (facile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Qadar en Islam ?', 'facile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le jeûne du Ramadan',false,0),(q,'La prière du destin',false,1),(q,'La croyance au destin divin (décret d''Allah)',true,2),(q,'La taxe religieuse',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Qadar (destin) est le sixième pilier de la foi : croire qu''Allah sait tout, a tout écrit, a voulu tout ce qui arrive et a créé toutes choses. C''est un pilier essentiel de l''Iman.',
   'إِنَّا كُلَّ شَيْءٍ خَلَقْنَاهُ بِقَدَرٍ',
   'Nous avons créé toute chose selon une mesure précise.',
   'Sourate Al-Qamar (54:49)');

-- Q135 (facile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est la signification de la Shahada "La ilaha illa Allah" ?', 'facile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Allah est le plus grand',false,0),(q,'Il n''y a de dieu qu''Allah',true,1),(q,'Muhammad est le messager d''Allah',false,2),(q,'Je crois en Allah',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'"La ilaha illa Allah" est la première partie de la Shahada. Elle signifie qu''il n''y a pas de vraie divinité digne d''adoration sauf Allah. C''est le fondement du Tawhid.',
   'شَهِدَ اللَّهُ أَنَّهُ لَا إِلَٰهَ إِلَّا هُوَ وَالْمَلَائِكَةُ وَأُولُو الْعِلْمِ',
   'Allah atteste qu''il n''y a de dieu que Lui, ainsi que les anges et les détenteurs du savoir.',
   'Sourate Aal-Imran (3:18)');

-- Lot 2a : moyen piliers + coran (Q136-Q170)

-- Q136 (moyen / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le taux de la Zakat sur l''or, l''argent et les économies ?', 'moyen', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'1%',false,0),(q,'2,5%',true,1),(q,'5%',false,2),(q,'10%',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le taux de Zakat sur l''or, l''argent et les économies est de 2,5% lorsque la richesse atteint le Nisab et qu''une année lunaire complète (Hawl) s''est écoulée.',
   'وَالَّذِينَ يَكْنِزُونَ الذَّهَبَ وَالْفِضَّةَ وَلَا يُنفِقُونَهَا فِي سَبِيلِ اللَّهِ فَبَشِّرْهُم بِعَذَابٍ أَلِيمٍ',
   'Ceux qui thésaurisent l''or et l''argent sans les dépenser dans le chemin d''Allah, annonce-leur un châtiment douloureux.',
   'Sourate At-Tawbah (9:34)');

-- Q137 (moyen / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Nisab pour la Zakat ?', 'moyen', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un montant fixé par le gouvernement',false,0),(q,'Le seuil minimum de richesse à partir duquel la Zakat devient obligatoire',true,1),(q,'La part réservée aux pauvres',false,2),(q,'Le taux annuel de la Zakat',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Nisab est le seuil minimum de richesse. Pour l''or : 85 grammes. Pour l''argent : 595 grammes. Si on possède cette richesse depuis un an lunaire, la Zakat est due.',
   'خُذْ مِنْ أَمْوَالِهِمْ صَدَقَةً تُطَهِّرُهُمْ وَتُزَكِّيهِم بِهَا',
   'Prélève de leurs biens une aumône pour les purifier et les sanctifier.',
   'Sourate At-Tawbah (9:103)');

-- Q138 (moyen / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la prière du Tarawih ?', 'moyen', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La prière obligatoire du Ramadan',false,0),(q,'La prière surérogatoire accomplie la nuit pendant le Ramadan',true,1),(q,'La prière du vendredi',false,2),(q,'La prière accomplie après le Fajr',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La prière du Tarawih est recommandée (Sunna Muakkadah) pendant les nuits du Ramadan. Le Prophète ﷺ a dit que celui qui la prie par foi et espérant la récompense, ses péchés passés sont pardonnés.',
   'مَنْ قَامَ رَمَضَانَ إِيمَانًا وَاحْتِسَابًا غُفِرَ لَهُ مَا تَقَدَّمَ مِن ذَنْبِهِ',
   'Celui qui se lève la nuit du Ramadan par foi et espérant la récompense, ses péchés passés lui seront pardonnés.',
   'Sahih Bukhari — Hadith n°37');

-- Q139 (moyen / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que l''Adhan ?', 'moyen', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La récitation du Coran dans la prière',false,0),(q,'L''appel à la prière lancé depuis la mosquée',true,1),(q,'La prière des funérailles',false,2),(q,'La supplication après la prière',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''Adhan est l''appel à la prière proclamé depuis le minaret de la mosquée cinq fois par jour. Il commence par "Allahu Akbar" et se termine par "La ilaha illa Allah".',
   'وَإِذَا نَادَيْتُمْ إِلَى الصَّلَاةِ اتَّخَذُوهَا هُزُوًا وَلَعِبًا',
   'Quand vous appelez à la prière, ils la prennent en moquerie et plaisanterie.',
   'Sourate Al-Ma''idah (5:58)');

-- Q140 (moyen / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Tawaf lors du Hajj ?', 'moyen', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La station à la montagne d''Arafat',false,0),(q,'Les 7 tours effectués autour de la Kaaba dans le sens antihoraire',true,1),(q,'La marche entre Safa et Marwa',false,2),(q,'Le sacrifice de l''Aïd',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Tawaf consiste à tourner 7 fois autour de la Kaaba dans le sens antihoraire. C''est l''un des actes essentiels du Hajj et de l''Umra, en commençant par la Pierre Noire.',
   'وَلْيَطَّوَّفُوا بِالْبَيْتِ الْعَتِيقِ',
   'Et qu''ils fassent la circumambulation autour de l''Antique Maison.',
   'Sourate Al-Hajj (22:29)');

-- Q141 (moyen / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Sa''y lors du Hajj et de l''Umra ?', 'moyen', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le jet de cailloux contre les stèles',false,0),(q,'La station à Mina',false,1),(q,'La marche 7 fois entre les collines de Safa et Marwa',true,2),(q,'La rasure du crâne',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Sa''y commémore la course de Hajar (mère d''Ismaïl) entre Safa et Marwa à la recherche d''eau pour son fils. Allah fit alors jaillir la source Zamzam.',
   'إِنَّ الصَّفَا وَالْمَرْوَةَ مِن شَعَائِرِ اللَّهِ',
   'Safa et Marwa sont parmi les symboles d''Allah.',
   'Sourate Al-Baqarah (2:158)');

-- Q142 (moyen / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Wuquf à Arafat pendant le Hajj ?', 'moyen', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La prière du soir à La Mecque',false,0),(q,'Le séjour et la station sur la plaine d''Arafat le 9 Dhul-Hijja',true,1),(q,'L''état d''Ihram',false,2),(q,'Le sacrifice du 10 Dhul-Hijja',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Wuquf (station) à Arafat est le pilier central du Hajj. Le Prophète ﷺ a dit : "Le Hajj c''est Arafat." Sans cette station le 9 Dhul-Hijja, le Hajj est invalide.',
   'الحَجُّ عَرَفَةُ',
   'Le Hajj, c''est Arafat.',
   'Sunan Abu Daoud — Hadith n°1949');

-- Q143 (moyen / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Laylat ul-Qadr ?', 'moyen', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La nuit du premier jour du Ramadan',false,0),(q,'La nuit de la naissance du Prophète ﷺ',false,1),(q,'La nuit du Destin, meilleure que 1000 mois',true,2),(q,'La nuit précédant l''Aïd',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Laylat ul-Qadr se trouve dans les 10 derniers jours du Ramadan, dans les nuits impaires. Elle vaut mieux que 1000 mois (environ 83 ans). Les anges descendent en grand nombre cette nuit.',
   'لَيْلَةُ الْقَدْرِ خَيْرٌ مِّنْ أَلْفِ شَهْرٍ',
   'La nuit du Destin est meilleure que mille mois.',
   'Sourate Al-Qadr (97:3)');

-- Q144 (moyen / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que l''I''tikaf ?', 'moyen', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le jeûne volontaire',false,0),(q,'La retraite spirituelle dans la mosquée',true,1),(q,'La prière de la nuit',false,2),(q,'La récitation intensive du Coran',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''I''tikaf est la retraite spirituelle dans la mosquée, particulièrement les 10 derniers jours du Ramadan. Le Prophète ﷺ ne l''abandonnait jamais.',
   'وَلَا تُبَاشِرُوهُنَّ وَأَنتُمْ عَاكِفُونَ فِي الْمَسَاجِدِ',
   'Ne vous approchez pas d''elles [vos épouses] quand vous êtes en retraite spirituelle dans les mosquées.',
   'Sourate Al-Baqarah (2:187)');

-- Q145 (moyen / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Tayammum ?', 'moyen', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Une prière spéciale en voyage',false,0),(q,'L''ablution avec la terre pure en absence d''eau ou en cas de maladie',true,1),(q,'La purification après impureté majeure',false,2),(q,'Un type de jeûne',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Tayammum est l''ablution symbolique avec de la terre pure, permise lorsqu''il n''y a pas d''eau disponible ou que l''utilisation d''eau est nuisible pour la santé.',
   'وَإِن كُنتُم مَّرْضَىٰ أَوْ عَلَىٰ سَفَرٍ أَوْ جَاءَ أَحَدٌ مِّنكُم مِّنَ الْغَائِطِ أَوْ لَامَسْتُمُ النِّسَاءَ فَلَمْ تَجِدُوا مَاءً فَتَيَمَّمُوا',
   'Si vous êtes malades, en voyage, ou si l''un de vous revient des toilettes... et ne trouvez pas d''eau, alors faites le Tayammum.',
   'Sourate Al-Ma''idah (5:6)');

-- Q146 (moyen / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelles sont les 8 catégories bénéficiaires de la Zakat selon le Coran ?', 'moyen', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Les pauvres, les orphelins, les voyageurs, les mosquées, les savants, les veuves, les réfugiés, les soldats',false,0),(q,'Les pauvres, les nécessiteux, les administrateurs, les convertis, les esclaves, les débiteurs, la cause d''Allah, les voyageurs',true,1),(q,'Les imams, les mosquées, les étudiants, les familles pauvres, les prisonniers, les malades',false,2),(q,'Seuls les pauvres et les nécessiteux',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Coran liste précisément les 8 catégories : Fuqara (pauvres), Masakin (nécessiteux), ''Amilin (administrateurs), Mu''allafat (convertis), Riqab (affranchissement), Gharimin (débiteurs), Fi Sabilillah (cause d''Allah), Ibnus Sabil (voyageurs).',
   'إِنَّمَا الصَّدَقَاتُ لِلْفُقَرَاءِ وَالْمَسَاكِينِ وَالْعَامِلِينَ عَلَيْهَا وَالْمُؤَلَّفَةِ قُلُوبُهُمْ وَفِي الرِّقَابِ وَالْغَارِمِينَ وَفِي سَبِيلِ اللَّهِ وَابْنِ السَّبِيلِ',
   'Les aumônes sont destinées aux pauvres, aux nécessiteux, à ceux qui les administrent, à ceux dont les cœurs sont à gagner, à l''affranchissement des esclaves, aux débiteurs, dans la voie d''Allah et aux voyageurs.',
   'Sourate At-Tawbah (9:60)');

-- Q147 (moyen / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de fois doit-on tourner autour de la Kaaba lors du Tawaf ?', 'moyen', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'3 fois',false,0),(q,'5 fois',false,1),(q,'7 fois',true,2),(q,'9 fois',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Tawaf consiste à tourner 7 fois autour de la Kaaba dans le sens antihoraire, en commençant et finissant par la Pierre Noire (Hajar al-Aswad).',
   'ثُمَّ لْيَقْضُوا تَفَثَهُمْ وَلْيُوفُوا نُذُورَهُمْ وَلْيَطَّوَّفُوا بِالْبَيْتِ الْعَتِيقِ',
   'Qu''ils s''acquittent de leurs obligations, accomplissent leurs vœux et fassent la circumambulation autour de l''Antique Maison.',
   'Sourate Al-Hajj (22:29)');

-- Q148 (moyen / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Ramy al-Jamarat ?', 'moyen', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le sacrifice du mouton',false,0),(q,'Le jet de cailloux sur les trois stèles symbolisant Satan',true,1),(q,'La rasure des cheveux',false,2),(q,'La station à Muzdalifa',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Ramy al-Jamarat (jet de cailloux) commémore le rejet d''Ibrahim de Satan quand il tenta de le détourner du sacrifice. On jette 7 cailloux sur chaque stèle à Mina.',
   'وَاذْكُرُوا اللَّهَ فِي أَيَّامٍ مَّعْدُودَاتٍ',
   'Rappelez-vous Allah pendant les jours comptés [de Mina].',
   'Sourate Al-Baqarah (2:203)');

-- Q149 (moyen / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Niyyah (intention) en Islam ?', 'moyen', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Une prière spécifique',false,0),(q,'L''intention dans le cœur précédant tout acte d''adoration',true,1),(q,'La récitation de la Fatiha',false,2),(q,'Le serment d''allégeance',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Niyyah est l''intention sincère dans le cœur. Elle est obligatoire pour valider les actes d''adoration. Elle n''est pas prononcée à voix haute en Islam selon la majorité des savants.',
   'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
   'Les actes ne valent que par les intentions, et chacun n''obtient que ce qu''il a voulu.',
   'Sahih Bukhari — Hadith n°1');

-- Q150 (moyen / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que l''Ihram lors du Hajj ?', 'moyen', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le sacrifice du Hajj',false,0),(q,'L''état rituel de pureté avec vêtements blancs pour le Hajj ou l''Umra',true,1),(q,'La prière spéciale du pèlerin',false,2),(q,'La rasure des cheveux',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''Ihram est l''état sacré de pureté rituelle. Pour les hommes : deux pièces de tissu blanc non cousu. Des interdictions s''appliquent : pas de parfum, pas de chasse, pas de rapports conjugaux.',
   'الْحَجُّ أَشْهُرٌ مَّعْلُومَاتٌ فَمَن فَرَضَ فِيهِنَّ الْحَجَّ فَلَا رَفَثَ وَلَا فُسُوقَ وَلَا جِدَالَ فِي الْحَجِّ',
   'Le Hajj se fait pendant des mois bien connus. Celui qui s''y oblige s''abstient de rapports intimes, d''actes de débauche et de disputes.',
   'Sourate Al-Baqarah (2:197)');

-- Q151 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le verset le plus long du Coran ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Ayat al-Kursi (2:255)',false,0),(q,'Le verset de la dette — Ayat al-Mudayanah (2:282)',true,1),(q,'Le verset du voile (24:31)',false,2),(q,'Le verset sur l''alcool (5:90)',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le verset 2:282 (Ayat al-Mudayanah — verset de la dette) est le plus long verset du Coran. Il traite des contrats financiers et impose de les consigner par écrit.',
   'يَا أَيُّهَا الَّذِينَ آمَنُوا إِذَا تَدَايَنتُم بِدَيْنٍ إِلَىٰ أَجَلٍ مُّسَمًّى فَاكْتُبُوهُ',
   'Ô croyants ! Quand vous contractez une dette à terme fixé, mettez-la en écrit.',
   'Sourate Al-Baqarah (2:282)');

-- Q152 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de sourates du Coran commencent par des lettres mystérieuses (Huruf al-Muqatta''at) ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'14 sourates',false,0),(q,'21 sourates',false,1),(q,'29 sourates',true,2),(q,'36 sourates',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'29 sourates commencent par des lettres isolées (Huruf al-Muqatta''at) comme Alif-Lam-Mim, Ya-Sin, etc. Leur sens exact n''est connu que d''Allah.',
   'الم ذَٰلِكَ الْكِتَابُ لَا رَيْبَ فِيهِ هُدًى لِّلْمُتَّقِينَ',
   'Alif-Lam-Mim. C''est le Livre en lequel il n''y a aucun doute, une direction pour les pieux.',
   'Sourate Al-Baqarah (2:1-2)');

-- Q153 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète est mentionné le plus souvent dans le Coran ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Ibrahim (Abraham) — 69 fois',false,0),(q,'Muhammad ﷺ — 4 fois',false,1),(q,'Moussa (Moïse) — 136 fois',true,2),(q,'Issa (Jésus) — 25 fois',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Moussa (Moïse) est le prophète mentionné le plus souvent dans le Coran, environ 136 fois. Son histoire occupe plus de place que celle de tout autre prophète.',
   'إِنَّا أَرْسَلْنَا مُوسَىٰ بِآيَاتِنَا أَنْ أَخْرِجْ قَوْمَكَ مِنَ الظُّلُمَاتِ إِلَى النُّورِ',
   'Nous avons envoyé Moussa avec Nos signes : Fais sortir ton peuple des ténèbres vers la lumière.',
   'Sourate Ibrahim (14:5)');

-- Q154 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle sourate est appelée "Umm al-Kitab" (Mère du Livre) ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Al-Baqarah',false,0),(q,'Al-Ikhlas',false,1),(q,'Ya-Sin',false,2),(q,'Al-Fatiha',true,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Al-Fatiha est appelée "Umm al-Kitab" car elle contient l''essence du Coran. Elle est aussi appelée "As-Sab al-Mathani" (les sept versets souvent répétés).',
   'وَلَقَدْ آتَيْنَاكَ سَبْعًا مِّنَ الْمَثَانِي وَالْقُرْآنَ الْعَظِيمَ',
   'Nous t''avons donné les sept qui se répètent (Al-Fatiha) et le Coran Immense.',
   'Sourate Al-Hijr (15:87)');

-- Q155 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Dans quelle sourate se trouve définitivement l''interdiction de l''alcool ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Al-Baqarah (2)',false,0),(q,'An-Nisa (4)',false,1),(q,'Al-Ma''idah (5)',true,2),(q,'Al-An''am (6)',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''interdiction finale de l''alcool se trouve dans Al-Ma''idah (5:90-91). L''interdiction fut révélée en 3 étapes : d''abord déconseillé (2:219), puis interdit avant la prière (4:43), puis interdit définitivement.',
   'يَا أَيُّهَا الَّذِينَ آمَنُوا إِنَّمَا الْخَمْرُ وَالْمَيْسِرُ وَالْأَنصَابُ وَالْأَزْلَامُ رِجْسٌ مِّنْ عَمَلِ الشَّيْطَانِ فَاجْتَنِبُوهُ',
   'Ô croyants ! Le vin, le jeu de hasard, les pierres sacrées et les flèches divinatoires ne sont qu''une abomination, œuvre du Diable. Évitez-les.',
   'Sourate Al-Ma''idah (5:90)');

-- Q156 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Tajwid ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La traduction du Coran',false,0),(q,'La mémorisation du Coran',false,1),(q,'Les règles de récitation correcte du Coran',true,2),(q,'L''interprétation du Coran',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Tajwid est la science de la récitation correcte du Coran : articulation des lettres, règles de prolongation, assimilation, pause. Le Coran doit être récité tel qu''il a été révélé.',
   'وَرَتِّلِ الْقُرْآنَ تَرْتِيلًا',
   'Et récite le Coran avec une récitation lente et distincte.',
   'Sourate Al-Muzzammil (73:4)');

-- Q157 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le premier verset révélé du Coran ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Al-Fatiha 1:1',false,0),(q,'Al-Mudassir 74:1',false,1),(q,'Al-''Alaq 96:1 — "Iqra bismi Rabbika alladhi khalaq"',true,2),(q,'Al-Baqarah 2:1',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le premier verset révélé est "Iqra bismi Rabbika" (96:1), révélé dans la grotte de Hira. C''est le début de la prophétie de Muhammad ﷺ à l''âge de 40 ans.',
   'اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ',
   'Lis au nom de ton Seigneur qui a créé.',
   'Sourate Al-''Alaq (96:1)');

-- Q158 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Tafsir ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La mémorisation du Coran',false,0),(q,'La traduction littérale du Coran',false,1),(q,'L''exégèse et l''interprétation du Coran',true,2),(q,'La récitation du Coran avec règles',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Tafsir est la science de l''interprétation et l''explication du Coran. Il existe plusieurs types : Tafsir bil-Ma''thur (par transmission), Tafsir bil-Ra''y (par opinion raisonnée).',
   'أَفَلَا يَتَدَبَّرُونَ الْقُرْآنَ وَلَوْ كَانَ مِنْ عِندِ غَيْرِ اللَّهِ لَوَجَدُوا فِيهِ اخْتِلَافًا كَثِيرًا',
   'Ne méditent-ils pas le Coran ? S''il venait d''un autre qu''Allah, ils y trouveraient de nombreuses contradictions.',
   'Sourate An-Nisa (4:82)');

-- Q159 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de Hizb contient le Coran ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'30 Hizb',false,0),(q,'40 Hizb',false,1),(q,'60 Hizb',true,2),(q,'114 Hizb',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Coran est divisé en 60 Hizb (demi-Juz chacun) ou en 240 Rub'' (quarts de Hizb). Cette division facilite la récitation quotidienne pour les lecteurs du Coran.',
   'إِنَّ هَٰذَا الْقُرْآنَ يَهْدِي لِلَّتِي هِيَ أَقْوَمُ',
   'Ce Coran guide vers ce qui est le plus droit.',
   'Sourate Al-Isra (17:9)');

-- Q160 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est la signification de "sourate Mecquoise" ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Une sourate qui parle de La Mecque',false,0),(q,'Une sourate révélée avant la Hijra (migration) à La Mecque',true,1),(q,'Une sourate récitée seulement à La Mecque',false,2),(q,'Une sourate longue du Coran',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les sourates mecquoises (86 sourates) ont été révélées avant la Hijra de 622 ap. J.-C. Elles traitent principalement du Tawhid, des prophètes et de l''Au-delà. Les sourates médinoises (28) traitent davantage de législation.',
   'وَكَذَٰلِكَ أَوْحَيْنَا إِلَيْكَ قُرْآنًا عَرَبِيًّا لِّتُنذِرَ أُمَّ الْقُرَىٰ وَمَنْ حَوْلَهَا',
   'Ainsi, Nous t''avons révélé un Coran arabe pour que tu avertisses la Mère des Cités [La Mecque] et ses alentours.',
   'Sourate Ash-Shura (42:7)');

-- Q161 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle sourate protège contre la Fitna du Dajjal selon les hadiths ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Al-Mulk',false,0),(q,'Ya-Sin',false,1),(q,'Al-Kahf',true,2),(q,'Al-Baqarah',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Prophète ﷺ a dit : Celui qui mémorise les 10 premiers versets de la sourate Al-Kahf sera protégé de la fitna du Dajjal. Cette sourate parle de l''épreuve de la religion, de la richesse, de la connaissance et du pouvoir.',
   'مَنْ حَفِظَ عَشْرَ آيَاتٍ مِنْ أَوَّلِ سُورَةِ الكَهْفِ عُصِمَ مِنَ الدَّجَّالِ',
   'Celui qui mémorise 10 versets du début de la sourate Al-Kahf sera protégé du Dajjal.',
   'Sahih Muslim — Hadith n°809');

-- Q162 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle sourate le Prophète ﷺ recommandait-il de réciter chaque nuit avant de dormir ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Al-Fatiha et Al-Baqarah',false,0),(q,'Al-Mulk (67)',true,1),(q,'Ya-Sin (36)',false,2),(q,'Al-Kahf (18)',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La sourate Al-Mulk est appelée "Al-Mani''ah" (qui protège) car elle protège son lecteur du châtiment du tombeau. Le Prophète ﷺ ne dormait pas sans la réciter.',
   'إِنَّ سُورَةً مِنَ الْقُرْآنِ ثَلَاثُونَ آيَةً شَفَعَتْ لِصَاحِبِهَا حَتَّى غُفِرَ لَهُ',
   'Une sourate du Coran de trente versets a intercédé pour son récitateur jusqu''à ce qu''il soit pardonné.',
   'Sunan Abu Daoud — Hadith n°1400');

-- Q163 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le "I''jaz al-Quran" (inimitabilité du Coran) ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La difficulté de mémoriser le Coran',false,0),(q,'Le fait que le Coran ne peut être égalé ou imité par aucun être humain',true,1),(q,'L''impossibilité de traduire le Coran',false,2),(q,'La science des sciences islamiques',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''inimitabilité du Coran est un défi lancé à l''humanité entière : produire une sourate semblable. Ce défi reste sans réponse depuis 14 siècles.',
   'قُل لَّئِنِ اجْتَمَعَتِ الْإِنسُ وَالْجِنُّ عَلَىٰ أَن يَأْتُوا بِمِثْلِ هَٰذَا الْقُرْآنِ لَا يَأْتُونَ بِمِثْلِهِ',
   'Dis : Si les hommes et les djinns s''unissaient pour produire quelque chose de semblable à ce Coran, ils n''y parviendraient pas.',
   'Sourate Al-Isra (17:88)');

-- Q164 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle sourate du Coran contient l''histoire des compagnons de la caverne ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Sourate Maryam (19)',false,0),(q,'Sourate Al-Anbiya (21)',false,1),(q,'Sourate Al-Kahf (18)',true,2),(q,'Sourate Ibrahim (14)',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La sourate Al-Kahf (18) contient l''histoire des Ahl al-Kahf (compagnons de la caverne) — des jeunes croyants qui se réfugièrent dans une grotte et y dormirent 309 ans pour fuir la persécution.',
   'أَمْ حَسِبْتَ أَنَّ أَصْحَابَ الْكَهْفِ وَالرَّقِيمِ كَانُوا مِنْ آيَاتِنَا عَجَبًا',
   'As-tu pensé que les compagnons de la Caverne et d''Al-Raqim étaient parmi Nos prodiges étonnants ?',
   'Sourate Al-Kahf (18:9)');

-- Q165 (moyen / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de sourates ne commencent pas par la Basmala dans le Coran ?', 'moyen', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'1 sourate (At-Tawbah)',true,0),(q,'3 sourates',false,1),(q,'5 sourates',false,2),(q,'7 sourates',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La sourate At-Tawbah (9) est la seule sourate à ne pas commencer par la Basmala. Les savants expliquent cela par son caractère de déclaration de guerre contre les hypocrites et associateurs.',
   'بَرَاءَةٌ مِّنَ اللَّهِ وَرَسُولِهِ إِلَى الَّذِينَ عَاهَدتُّم مِّنَ الْمُشْرِكِينَ',
   'Déclaration de désaveu de la part d''Allah et de Son Messager, envers les associateurs avec qui vous avez conclu un traité.',
   'Sourate At-Tawbah (9:1)');

-- Lot 2b : moyen hadith + histoire (Q166-Q200)

-- Q166 (moyen / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quels sont les six grands recueils de hadiths (Kutub as-Sittah) ?', 'moyen', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Bukhari, Muslim, Muwatta, Musnad Ahmad, Tabari, Ibn Kathir',false,0),(q,'Bukhari, Muslim, Abu Daoud, Tirmidhi, An-Nasa''i, Ibn Majah',true,1),(q,'Bukhari, Muslim, Bayhaqi, Daraqutni, Ibn Hibban, Hakim',false,2),(q,'Bukhari, Muslim, Shafi''i, Ahmad, Malik, Hanbal',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les Kutub as-Sittah (Six Livres) sont les six collections de hadiths les plus authentiques : Bukhari, Muslim, Abu Daoud, Tirmidhi, An-Nasa''i et Ibn Majah.',
   'إِنِّي تَرَكْتُ فِيكُمْ شَيْئَيْنِ لَنْ تَضِلُّوا بَعْدَهُمَا كِتَابَ اللَّهِ وَسُنَّتِي',
   'Je vous laisse deux choses : vous ne vous égarerez jamais si vous y adhérez — le Livre d''Allah et ma Sunna.',
   'Muwatta Malik — Hadith n°1661');

-- Q167 (moyen / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce qu''un Hadith Sahih (authentique) ?', 'moyen', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Tout hadith présent dans Bukhari ou Muslim',false,0),(q,'Un hadith avec chaîne continue, transmis par des narrateurs fiables et mémorisants, sans anomalie ni défaut',true,1),(q,'Un hadith approuvé par l''imam Shafi''i',false,2),(q,'Un hadith qui ne contredit pas le Coran',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Un Hadith Sahih remplit 5 conditions : chaîne continue, narrateurs fiables, narrateurs mémorisants, absence d''anomalie (Shadh) et absence de défaut caché (Illah).',
   'فَلْيَحْذَرِ الَّذِينَ يُخَالِفُونَ عَنْ أَمْرِهِ أَن تُصِيبَهُمْ فِتْنَةٌ أَوْ يُصِيبَهُمْ عَذَابٌ أَلِيمٌ',
   'Que ceux qui s''opposent à son ordre prennent garde qu''une épreuve ne les frappe ou qu''un châtiment douloureux ne s''abatte sur eux.',
   'Sourate An-Nur (24:63)');

-- Q168 (moyen / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que l''Isnad d''un hadith ?', 'moyen', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le texte du hadith',false,0),(q,'La chaîne de transmetteurs du hadith',true,1),(q,'Le contexte historique du hadith',false,2),(q,'La classification du hadith',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''Isnad est la chaîne de transmetteurs qui relie l''auteur du recueil au Prophète ﷺ. L''imam al-Bukhari a dit : "L''Isnad fait partie de la religion."',
   'إِنَّ هَذَا الْعِلْمَ دِينٌ فَانْظُرُوا عَمَّنْ تَأْخُذُونَ دِينَكُمْ',
   'Cette connaissance est une religion, regardez donc de qui vous prenez votre religion.',
   'Muqaddimah Sahih Muslim');

-- Q169 (moyen / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce qu''un Hadith Mawdu'' ?', 'moyen', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un hadith transmis par peu de personnes',false,0),(q,'Un hadith dont la chaîne est interrompue',false,1),(q,'Un hadith forgé et inventé, attribué faussement au Prophète ﷺ',true,2),(q,'Un hadith faible mais pas interdit',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Hadith Mawdu'' est un hadith inventé et attribué faussement au Prophète ﷺ. C''est le plus bas niveau de hadith. Le Prophète ﷺ a averti sévèrement contre la fabrication de hadiths.',
   'مَنْ كَذَبَ عَلَيَّ مُتَعَمِّدًا فَلْيَتَبَوَّأْ مَقْعَدَهُ مِنَ النَّارِ',
   'Celui qui ment délibérément en mon nom, qu''il prépare sa place dans le Feu.',
   'Sahih Bukhari — Hadith n°110');

-- Q170 (moyen / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce qu''un Hadith Mutawatir ?', 'moyen', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un hadith rapporté par un seul transmetteur',false,0),(q,'Un hadith transmis par tant de personnes que toute invention concertée est impossible',true,1),(q,'Un hadith transmis uniquement par des Compagnons',false,2),(q,'Un hadith confirmé par deux recueils différents',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Un Hadith Mutawatir est transmis par un si grand nombre de personnes à chaque génération qu''une entente pour le fabriquer est impossible. Il procure une certitude absolue.',
   'وَالسَّابِقُونَ الْأَوَّلُونَ مِنَ الْمُهَاجِرِينَ وَالْأَنصَارِ وَالَّذِينَ اتَّبَعُوهُم بِإِحْسَانٍ رَّضِيَ اللَّهُ عَنْهُمْ',
   'Les premiers à avoir émigré et à avoir aidé [l''Islam], et ceux qui les ont suivis en bien, Allah est satisfait d''eux.',
   'Sourate At-Tawbah (9:100)');

-- Q171 (moyen / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qui a compilé le Muwatta, premier grand recueil de hadiths et de jurisprudence ?', 'moyen', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'L''imam Ahmad ibn Hanbal',false,0),(q,'L''imam Malik ibn Anas',true,1),(q,'L''imam ash-Shafi''i',false,2),(q,'L''imam al-Bukhari',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''imam Malik ibn Anas (m. 795) compila le Muwatta, le plus ancien recueil de hadiths qui nous soit parvenu. Il contient environ 1720 hadiths et est fondateur de l''école Malikite.',
   'يُوشِكُ أَنْ يَضْرِبَ النَّاسُ أَكْبَادَ الإِبِلِ يَطْلُبُونَ الْعِلْمَ فَلَا يَجِدُونَ أَحَدًا أَعْلَمَ مِنْ عَالِمِ الْمَدِينَةِ',
   'Les gens voyageront peut-être à dos de chameau cherchant la connaissance, sans trouver personne de plus savant que le savant de Médine.',
   'Jami'' at-Tirmidhi — Hadith n°2680');

-- Q172 (moyen / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la science du "Rijal" en études de hadith ?', 'moyen', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'L''étude du texte des hadiths',false,0),(q,'L''évaluation de la fiabilité des transmetteurs de hadiths',true,1),(q,'L''authentification des hadiths par comparaison',false,2),(q,'L''étude de la jurisprudence islamique',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La science du Rijal (Asma'' al-Rijal) est l''étude biographique des transmetteurs de hadiths pour évaluer leur fiabilité (''Adala) et leur mémoire (Dabt). C''est une science unique à l''Islam.',
   'إِنَّ هَذَا الْعِلْمَ دِينٌ فَانْظُرُوا عَمَّنْ تَأْخُذُونَ دِينَكُمْ',
   'Cette connaissance est une religion, regardez donc de qui vous prenez votre religion.',
   'Muqaddimah Sahih Muslim');

-- Q173 (moyen / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Matn d''un hadith ?', 'moyen', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La chaîne de transmetteurs',false,0),(q,'Le texte et le contenu même du hadith',true,1),(q,'La classification du hadith',false,2),(q,'Le nombre de transmetteurs',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Matn est le corps du texte du hadith — les paroles ou actes effectifs du Prophète ﷺ, par opposition à l''Isnad qui est la chaîne de transmission.',
   'بَلِّغُوا عَنِّي وَلَوْ آيَةً',
   'Transmettez de ma part, même si c''est un seul verset.',
   'Sahih Bukhari — Hadith n°3461');

-- Q174 (moyen / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le "Jarh wa at-Ta''dil" ?', 'moyen', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Une prière spéciale du Ramadan',false,0),(q,'La science d''affaiblir ou accréditer les transmetteurs de hadiths',true,1),(q,'Le jugement des litiges islamiques',false,2),(q,'La récitation du Coran en groupe',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Jarh (affaiblissement) et at-Ta''dil (accréditation) sont deux processus par lesquels les savants évaluent les transmetteurs de hadiths. C''est la "critique des sources" islamique.',
   'يَا أَيُّهَا الَّذِينَ آمَنُوا إِن جَاءَكُمْ فَاسِقٌ بِنَبَإٍ فَتَبَيَّنُوا',
   'Ô croyants ! Si un pervers vous apporte une nouvelle, vérifiez-la.',
   'Sourate Al-Hujurat (49:6)');

-- Q175 (moyen / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce qu''un Hadith Hasan ?', 'moyen', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un beau hadith du point de vue littéraire',false,0),(q,'Un hadith qui remplit les conditions du Sahih sauf sur la mémorisation',true,1),(q,'Un hadith que deux imams ont accepté',false,2),(q,'Un hadith invoquant la miséricorde d''Allah',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Un Hadith Hasan est légèrement inférieur au Sahih en authenticité. Il remplit toutes les conditions mais l''un des transmetteurs est légèrement moins fiable dans sa mémorisation. Il est utilisable en jurisprudence.',
   'وَمَن يُطِعِ اللَّهَ وَرَسُولَهُ فَقَدْ فَازَ فَوْزًا عَظِيمًا',
   'Celui qui obéit à Allah et à Son Messager a remporté une immense victoire.',
   'Sourate Al-Ahzab (33:71)');

-- Q176 (moyen / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel hadith célèbre enseigne que "La religion c''est la sincérité" (An-Nasiha) ?', 'moyen', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Hadith de Jibril',false,0),(q,'Hadith des intentions',false,1),(q,'Hadith de Tamim al-Dari sur An-Nasiha',true,2),(q,'Hadith des 5 piliers',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Prophète ﷺ a dit trois fois : "La religion, c''est la sincérité (An-Nasiha)." Les Compagnons demandèrent : "Pour qui ?" Il répondit : "Pour Allah, Son Livre, Son Messager, les dirigeants et les musulmans en général."',
   'الدِّينُ النَّصِيحَةُ',
   'La religion, c''est la sincérité.',
   'Sahih Muslim — Hadith n°55');

-- Q177 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien d''années a duré la phase mecquoise de la prophétie ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'7 ans',false,0),(q,'10 ans',false,1),(q,'13 ans',true,2),(q,'20 ans',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La période mecquoise de la prophétie dura 13 ans (610-622 ap. J.-C.). Elle fut marquée par la prédication discrète puis publique, la persécution des musulmans et l''invitation des tribus.',
   'فَاصْبِرْ كَمَا صَبَرَ أُولُو الْعَزْمِ مِنَ الرُّسُلِ',
   'Sois patient comme ont été patients les messagers de ferme résolution.',
   'Sourate Al-Ahqaf (46:35)');

-- Q178 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom du deuxième calife de l''Islam ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Abu Bakr As-Siddiq',false,0),(q,'Umar ibn al-Khattab',true,1),(q,'Uthman ibn Affan',false,2),(q,'Ali ibn Abi Talib',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Umar ibn al-Khattab (m. 644) fut le deuxième calife. Sous son règne, l''Islam s''étendit en Perse, en Égypte et en Syrie. Il était connu pour sa justice et sa rigueur.',
   'لَوْ كَانَ بَعْدِي نَبِيٌّ لَكَانَ عُمَرَ بْنَ الْخَطَّابِ',
   'S''il devait y avoir un prophète après moi, ce serait Umar ibn al-Khattab.',
   'Jami'' at-Tirmidhi — Hadith n°3686');

-- Q179 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qui a compilé le Coran en un seul codex sous le califat d''Abu Bakr ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Umar ibn al-Khattab',false,0),(q,'Ali ibn Abi Talib',false,1),(q,'Zayd ibn Thabit',true,2),(q,'Uthman ibn Affan',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Zayd ibn Thabit, le principal scribe du Prophète ﷺ, fut chargé par Abu Bakr de compiler le Coran après la bataille de Yamama où beaucoup de Huffaz (mémoriseurs) furent martyrisés.',
   'إِنَّا نَحْنُ نَزَّلْنَا الذِّكْرَ وَإِنَّا لَهُ لَحَافِظُونَ',
   'C''est Nous qui avons fait descendre le Rappel et Nous en sommes les gardiens.',
   'Sourate Al-Hijr (15:9)');

-- Q180 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Lors de quelle bataille le Prophète ﷺ a-t-il été blessé ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La bataille de Badr',false,0),(q,'La bataille d''Uhud',true,1),(q,'La bataille du Fossé',false,2),(q,'La bataille de Khaybar',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Lors de la bataille d''Uhud (625 ap. J.-C.), le Prophète ﷺ fut blessé au visage, perdit une dent et s''évanouit. 70 compagnons furent martyrisés, dont Hamza ibn Abdul-Muttalib.',
   'وَلَقَدْ صَدَقَكُمُ اللَّهُ وَعْدَهُ إِذْ تَحُسُّونَهُم بِإِذْنِهِ',
   'Allah a tenu Sa promesse envers vous quand vous les terrassiez par Sa permission.',
   'Sourate Aal-Imran (3:152)');

-- Q181 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel était le nom de la première mosquée construite par le Prophète ﷺ ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Al-Masjid An-Nabawi',false,0),(q,'Al-Masjid Al-Haram',false,1),(q,'Masjid Quba',true,2),(q,'Masjid Al-Aqsa',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Masjid Quba fut la première mosquée construite par le Prophète ﷺ lors de son arrivée à Médine. Une prière de 2 rak''aat à Quba vaut la récompense d''une Umra.',
   'لَّمَسْجِدٌ أُسِّسَ عَلَى التَّقْوَىٰ مِنْ أَوَّلِ يَوْمٍ أَحَقُّ أَن تَقُومَ فِيهِ',
   'Une mosquée fondée sur la piété dès le premier jour mérite mieux que tu y pries.',
   'Sourate At-Tawbah (9:108)');

-- Q182 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom de la bataille où les musulmans creusèrent un fossé pour se défendre ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La bataille de Badr',false,0),(q,'La bataille d''Uhud',false,1),(q,'La bataille du Fossé (Al-Khandaq)',true,2),(q,'La bataille de Hunayn',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La bataille du Fossé (627 ap. J.-C.) : sur conseil de Salman al-Farisi, les musulmans creusèrent un fossé autour de Médine. La coalition de 10 000 ennemis ne put traverser et se retira.',
   'يَا أَيُّهَا الَّذِينَ آمَنُوا اذْكُرُوا نِعْمَةَ اللَّهِ عَلَيْكُمْ إِذْ جَاءَتْكُمْ جُنُودٌ فَأَرْسَلْنَا عَلَيْهِمْ رِيحًا',
   'Ô croyants ! Rappelez-vous le bienfait d''Allah sur vous quand des armées vinrent contre vous. Nous envoyâmes contre elles un vent.',
   'Sourate Al-Ahzab (33:9)');

-- Q183 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom du traité de paix conclu entre le Prophète ﷺ et les Quraychites en l''an 6 AH ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le Traité de Badr',false,0),(q,'Le Pacte de Médine',false,1),(q,'Le Traité de Hudaybiyah',true,2),(q,'L''Accord d''Uhud',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Traité de Hudaybiyah (628 ap. J.-C.) fut un accord de paix de 10 ans entre le Prophète ﷺ et les Quraychites. Allah l''appela "victoire manifeste" car il permit l''expansion de l''Islam.',
   'إِنَّا فَتَحْنَا لَكَ فَتْحًا مُّبِينًا',
   'Nous t''avons accordé une victoire manifeste.',
   'Sourate Al-Fath (48:1)');

-- Q184 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom du premier sermon du Prophète ﷺ lors du dernier pèlerinage ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le Sermon de Badr',false,0),(q,'Le Sermon d''Uhud',false,1),(q,'Le Sermon de l''Adieu (Khutbat al-Wada'')',true,2),(q,'Le Sermon du Fossé',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Sermon de l''Adieu (632 ap. J.-C.) fut prononcé sur le Mont Arafat lors du dernier Hajj. Le Prophète ﷺ y proclama l''égalité des hommes, les droits de la femme et l''interdiction du Riba.',
   'الْيَوْمَ أَكْمَلْتُ لَكُمْ دِينَكُمْ وَأَتْمَمْتُ عَلَيْكُمْ نِعْمَتِي وَرَضِيتُ لَكُمُ الْإِسْلَامَ دِينًا',
   'Aujourd''hui, J''ai parachevé pour vous votre religion et accompli Ma grâce sur vous. J''agrée l''Islam comme religion pour vous.',
   'Sourate Al-Ma''idah (5:3)');

-- Q185 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel calife a ordonné la standardisation du Coran et la destruction des copies non conformes ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Abu Bakr As-Siddiq',false,0),(q,'Umar ibn al-Khattab',false,1),(q,'Uthman ibn Affan',true,2),(q,'Ali ibn Abi Talib',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le calife Uthman ibn Affan (m. 656) fit standardiser le Coran en une seule version sous la direction de Zayd ibn Thabit. Des copies furent envoyées dans toutes les provinces.',
   'إِنَّا نَحْنُ نَزَّلْنَا الذِّكْرَ وَإِنَّا لَهُ لَحَافِظُونَ',
   'C''est Nous qui avons fait descendre le Rappel et Nous en sommes les gardiens.',
   'Sourate Al-Hijr (15:9)');

-- Q186 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qui était Khalid ibn al-Walid et pourquoi est-il célèbre ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le premier muezzin de l''Islam',false,0),(q,'Le scribe du Prophète ﷺ',false,1),(q,'Le grand général militaire islamique, surnommé "Épée d''Allah"',true,2),(q,'Le gouverneur de Médine',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Khalid ibn al-Walid fut l''un des plus grands généraux de l''histoire. Après sa conversion à l''Islam, il remporta des victoires décisives à Yarmouk, en Perse et en Syrie, sans jamais perdre une bataille.',
   'نِعْمَ عَبْدُ اللَّهِ وَأَخُو الْعَشِيرَةِ وَسَيْفٌ مِنْ سُيُوفِ اللَّهِ',
   'Quel bon serviteur d''Allah et frère de tribu ! Il est une épée parmi les épées d''Allah.',
   'Sahih Bukhari — Hadith n°4262');

-- Q187 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est la signification du "Pacte de Médine" (Sahifat al-Madinah) ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le contrat de mariage du Prophète ﷺ',false,0),(q,'La constitution de Médine réglant la coexistence entre muslims, juifs et tribus',true,1),(q,'L''accord de paix avec les Quraychites',false,2),(q,'Le traité de cessez-le-feu après Badr',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Pacte de Médine (622 ap. J.-C.) fut le premier document constitutionnel de l''État islamique. Il définissait les droits et obligations de tous les habitants de Médine, musulmans et non-musulmans.',
   'يَا أَيُّهَا النَّاسُ إِنَّا خَلَقْنَاكُم مِّن ذَكَرٍ وَأُنثَىٰ وَجَعَلْنَاكُمْ شُعُوبًا وَقَبَائِلَ لِتَعَارَفُوا',
   'Ô hommes ! Nous vous avons créés d''un mâle et d''une femelle, et Nous avons fait de vous des nations et des tribus pour que vous vous entre-connaissiez.',
   'Sourate Al-Hujurat (49:13)');

-- Q188 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qui était Salman al-Farisi et quelle fut sa contribution à l''Islam ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le premier muezzin — il appela à la prière',false,0),(q,'Le compagnon persan qui conseilla de creuser un fossé à la bataille du Fossé',true,1),(q,'Le général qui conquit la Perse',false,2),(q,'Le gouverneur d''Iran sous Umar',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Salman al-Farisi, originaire de Perse, chercha la vraie religion pendant des années avant d''embrasser l''Islam. Son idée du fossé lors de la bataille du Khandaq sauva Médine.',
   'لَوْ كَانَ الإِيمَانُ عِنْدَ الثُّرَيَّا لَنَالَهُ رَجُلٌ مِنْ فَارِسَ',
   'Si la foi se trouvait aux Pléiades, un homme de Perse la saisirait.',
   'Sahih Bukhari — Hadith n°4897');

-- Q189 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Seerah du Prophète ﷺ ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Les hadiths du Prophète ﷺ',false,0),(q,'La biographie du Prophète Muhammad ﷺ',true,1),(q,'Les commentaires du Coran',false,2),(q,'La jurisprudence islamique',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Seerah est la biographie du Prophète ﷺ. Elle couvre sa vie depuis sa naissance, sa mission prophétique, ses combats, ses migrations jusqu''à sa mort. Le plus célèbre auteur est Ibn Ishaq.',
   'لَّقَدْ كَانَ لَكُمْ فِي رَسُولِ اللَّهِ أُسْوَةٌ حَسَنَةٌ',
   'Vous avez dans le Messager d''Allah un excellent modèle.',
   'Sourate Al-Ahzab (33:21)');

-- Q190 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle fut la première nation à embrasser l''Islam en masse (hors Arabie) ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'L''Égypte',false,0),(q,'La Perse',false,1),(q,'L''Abyssinie (Éthiopie)',true,2),(q,'La Syrie',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Négus (roi) d''Abyssinie (Éthiopie) accorda refuge aux premiers musulmans persécutés et embrassa lui-même l''Islam. Le Prophète ﷺ pria sa prière funèbre à Médine quand il mourut.',
   'إِنَّ الَّذِينَ آمَنُوا وَالَّذِينَ هَاجَرُوا وَجَاهَدُوا فِي سَبِيلِ اللَّهِ أُولَٰئِكَ يَرْجُونَ رَحْمَتَ اللَّهِ',
   'Ceux qui ont cru, émigré et lutté dans le chemin d''Allah espèrent la miséricorde d''Allah.',
   'Sourate Al-Baqarah (2:218)');

-- Q191 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quand commença le calendrier islamique (Hijri) et quel en est le point de départ ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La naissance du Prophète ﷺ en 570 ap. J.-C.',false,0),(q,'La première révélation du Coran en 610 ap. J.-C.',false,1),(q,'La Hijra (migration à Médine) en 622 ap. J.-C.',true,2),(q,'La conquête de La Mecque en 630 ap. J.-C.',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le calendrier islamique (Hijri) fut institué par le calife Umar ibn al-Khattab et prend pour point de départ la Hijra du Prophète ﷺ à Médine en 622 ap. J.-C. Il est lunaire (354 jours).',
   'هُوَ الَّذِي جَعَلَ الشَّمْسَ ضِيَاءً وَالْقَمَرَ نُورًا وَقَدَّرَهُ مَنَازِلَ لِتَعْلَمُوا عَدَدَ السِّنِينَ وَالْحِسَابَ',
   'C''est Lui qui a fait du soleil une clarté et de la lune une lumière, et en a déterminé les phases pour que vous connaissiez le nombre des années et le calcul du temps.',
   'Sourate Yunus (10:5)');

-- Q192 (moyen / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qui fut le général qui conquit l''Égypte pour l''Islam ?', 'moyen', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Khalid ibn al-Walid',false,0),(q,'Abu Ubayda ibn al-Jarrah',false,1),(q,'Amr ibn al-As',true,2),(q,'Sa''d ibn Abi Waqqas',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Amr ibn al-As conquit l''Égypte en 641 ap. J.-C. sous le califat de Umar ibn al-Khattab. Il fonda Fustat (ancêtre du Caire) et fit de l''Égypte une province islamique florissante.',
   'فَسِيرُوا فِي الْأَرْضِ فَانظُرُوا كَيْفَ كَانَ عَاقِبَةُ الْمُكَذِّبِينَ',
   'Parcourez la terre et regardez ce qu''il est advenu de ceux qui niaient.',
   'Sourate Al-Imran (3:137)');

-- Lot 2c : moyen jurisprudence + prophetes + foi (Q193-Q240)

-- Q193 (moyen / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelles sont les sources principales du droit islamique (Usul al-Fiqh) dans l''ordre de priorité ?', 'moyen', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Opinion des savants, Coran, Sunna, consensus',false,0),(q,'Coran, Sunna, Ijma'' (consensus), Qiyas (analogie)',true,1),(q,'Coran, Ijma'', Qiyas, Ijtihad',false,2),(q,'Sunna, Coran, Tafsir, Hadith',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''Usul al-Fiqh identifie 4 sources principales : le Coran (parole d''Allah), la Sunna (pratique du Prophète ﷺ), l''Ijma'' (consensus des savants) et le Qiyas (raisonnement par analogie).',
   'يَا أَيُّهَا الَّذِينَ آمَنُوا أَطِيعُوا اللَّهَ وَأَطِيعُوا الرَّسُولَ وَأُولِي الْأَمْرِ مِنكُمْ',
   'Ô croyants ! Obéissez à Allah, obéissez au Messager et à ceux d''entre vous qui détiennent l''autorité.',
   'Sourate An-Nisa (4:59)');

-- Q194 (moyen / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelles sont les quatre grandes écoles juridiques sunnites (Madhahib) ?', 'moyen', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Hanafite, Malikite, Shafi''ite, Hanbalite',true,0),(q,'Bukhariste, Muslimite, Malikite, Shafi''ite',false,1),(q,'Ash''arite, Maturidite, Hanafite, Zahirite',false,2),(q,'Salafiste, Soufiste, Hanafite, Malikite',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les 4 madhahib sunnites : Hanafite (fondé par Abu Hanifa, m. 767), Malikite (Malik, m. 795), Shafi''ite (Shafi''i, m. 820), Hanbalite (Ahmad, m. 855). Toutes s''appuient sur le Coran et la Sunna.',
   'فَاسْأَلُوا أَهْلَ الذِّكْرِ إِن كُنتُمْ لَا تَعْلَمُونَ',
   'Interrogez les gens du Rappel si vous ne savez pas.',
   'Sourate An-Nahl (16:43)');

-- Q195 (moyen / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que l''Ijma'' en jurisprudence islamique ?', 'moyen', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le raisonnement personnel d''un savant',false,0),(q,'Le vote de la majorité des musulmans',false,1),(q,'Le consensus des savants qualifiés sur une question juridique',true,2),(q,'L''opinion du calife',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''Ijma'' est le consensus des mujtahidun (savants qualifiés) sur une question juridique. Il est la troisième source du droit islamique. Si tous les savants d''une époque s''accordent, c''est obligatoire.',
   'وَمَن يُشَاقِقِ الرَّسُولَ مِن بَعْدِ مَا تَبَيَّنَ لَهُ الْهُدَىٰ وَيَتَّبِعْ غَيْرَ سَبِيلِ الْمُؤْمِنِينَ',
   'Celui qui s''oppose au Messager après que la bonne voie lui est clairement apparue et qui suit une voie autre que celle des croyants...',
   'Sourate An-Nisa (4:115)');

-- Q196 (moyen / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Qiyas en jurisprudence islamique ?', 'moyen', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La prière analogique',false,0),(q,'L''opinion personnelle d''un imam',false,1),(q,'Le raisonnement par analogie à partir du Coran ou de la Sunna',true,2),(q,'Le consensus des Compagnons',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Qiyas est l''analogie juridique : appliquer une règle établie dans le Coran ou la Sunna à un cas similaire non explicitement mentionné. Ex : la drogue est interdite par analogie avec l''alcool.',
   'يَا أَيُّهَا الَّذِينَ آمَنُوا لَا تَسْأَلُوا عَنْ أَشْيَاءَ إِن تُبْدَ لَكُمْ تَسُؤْكُمْ',
   'Ô croyants ! Ne posez pas de questions sur des choses que si elles vous étaient révélées vous déplairaient.',
   'Sourate Al-Ma''idah (5:101)');

-- Q197 (moyen / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que l''Idda en droit islamique ?', 'moyen', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La dot du mariage',false,0),(q,'La période d''attente obligatoire après un divorce ou le décès du mari',true,1),(q,'La prière funèbre',false,2),(q,'La période d''allaitement',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''Idda est la période durant laquelle une femme divorcée ou veuve ne peut pas se remarier. Pour la divorcée : 3 cycles menstruels. Pour la veuve : 4 mois et 10 jours.',
   'وَالْمُطَلَّقَاتُ يَتَرَبَّصْنَ بِأَنفُسِهِنَّ ثَلَاثَةَ قُرُوءٍ',
   'Les femmes divorcées doivent attendre trois périodes menstruelles.',
   'Sourate Al-Baqarah (2:228)');

-- Q198 (moyen / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Talaq dans l''Islam — combien de fois peut-on le prononcer avant qu''il soit irrévocable ?', 'moyen', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Une seule fois',false,0),(q,'Deux fois',false,1),(q,'Trois fois (le troisième est irrévocable)',true,2),(q,'Quatre fois',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Talaq est révocable 1 ou 2 fois. À la troisième répudiation, il devient irrévocable. La femme ne peut pas revenir à son ex-mari sans avoir épousé et divorcé sincèrement d''un autre homme.',
   'الطَّلَاقُ مَرَّتَانِ فَإِمْسَاكٌ بِمَعْرُوفٍ أَوْ تَسْرِيحٌ بِإِحْسَانٍ',
   'Le divorce est deux fois. Ensuite, c''est soit la rétention avec bienveillance, soit la libération avec courtoisie.',
   'Sourate Al-Baqarah (2:229)');

-- Q199 (moyen / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quels sont les 5 objectifs généraux (Maqasid) de la Sharia ?', 'moyen', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Foi, Prière, Jeûne, Zakat, Hajj',false,0),(q,'Préserver la religion, la vie, l''intellect, la descendance et la richesse',true,1),(q,'La justice, l''égalité, la fraternité, la paix et la liberté',false,2),(q,'Coran, Sunna, Ijma'', Qiyas, Ijtihad',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les 5 Maqasid (objectifs) de la Sharia identifiés par Al-Ghazali : préserver la religion (Din), la vie (Nafs), l''intellect (Aql), la descendance (Nasl) et la richesse (Mal). Toute loi islamique vise à protéger ces 5 éléments.',
   'وَلَا تُفْسِدُوا فِي الْأَرْضِ بَعْدَ إِصْلَاحِهَا',
   'Et ne semez pas la corruption sur la terre après qu''elle a été réformée.',
   'Sourate Al-A''raf (7:56)');

-- Q200 (moyen / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Murabaha en finance islamique ?', 'moyen', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un prêt avec intérêt fixe',false,0),(q,'Une vente à profit déclaré où l''acheteur connaît le coût et la marge',true,1),(q,'Un contrat d''assurance islamique',false,2),(q,'Un fonds d''investissement islamique',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Murabaha est un contrat de vente islamique où le vendeur informe l''acheteur de son prix de revient et de sa marge bénéficiaire. C''est une alternative islamique au crédit bancaire avec intérêt.',
   'وَأَحَلَّ اللَّهُ الْبَيْعَ وَحَرَّمَ الرِّبَا',
   'Allah a rendu licite le commerce et illicite l''usure.',
   'Sourate Al-Baqarah (2:275)');

-- Q201 (moyen / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Wasiyyah (testament) islamique et quelle est sa limite ?', 'moyen', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'On peut léguer tous ses biens à qui on veut',false,0),(q,'On ne peut léguer qu''aux héritiers directs',false,1),(q,'On peut léguer un maximum d''1/3 des biens à des non-héritiers',true,2),(q,'Le testament n''est pas reconnu en Islam',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Wasiyyah permet de léguer jusqu''à 1/3 des biens. Les 2/3 restants sont distribués selon les règles d''héritage islamique (Mawarith). On ne peut pas faire de testament en faveur d''un héritier légal.',
   'كُتِبَ عَلَيْكُمْ إِذَا حَضَرَ أَحَدَكُمُ الْمَوْتُ إِن تَرَكَ خَيْرًا الْوَصِيَّةُ لِلْوَالِدَيْنِ وَالْأَقْرَبِينَ',
   'Il vous est prescrit, quand la mort approche de l''un de vous, s''il laisse des biens, de faire le testament en faveur de ses père, mère et proches.',
   'Sourate Al-Baqarah (2:180)');

-- Q202 (moyen / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le principe de "La Darura Tubih al-Mahzurat" en fiqh islamique ?', 'moyen', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Tout est permis si on a l''intention correcte',false,0),(q,'La nécessité absolue permet ce qui est habituellement interdit',true,1),(q,'La Sharia est suspendue en temps de guerre',false,2),(q,'Les dirigeants peuvent modifier les lois islamiques',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Darura (nécessité) est un principe clé du fiqh : ce qui est interdit peut devenir permis en cas de nécessité vitale absolue. Ex : manger du porc si c''est la seule alternative à la mort.',
   'فَمَنِ اضْطُرَّ غَيْرَ بَاغٍ وَلَا عَادٍ فَلَا إِثْمَ عَلَيْهِ',
   'Celui qui y est contraint, sans désir et sans transgression, ne commet pas de péché.',
   'Sourate Al-Baqarah (2:173)');

-- Q203 (moyen / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Wali (tuteur) dans le contexte du mariage islamique ?', 'moyen', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le juge islamique (Qadi)',false,0),(q,'Le tuteur masculin (père, frère, oncle) de la femme qui représente ses intérêts lors du mariage',true,1),(q,'Le témoin du mariage',false,2),(q,'L''imam qui marie le couple',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Wali est le tuteur de la mariée. Selon la majorité des savants, le mariage nécessite la présence et l''accord du Wali. Il agit dans l''intérêt de la femme.',
   'لَا نِكَاحَ إِلَّا بِوَلِيٍّ',
   'Pas de mariage sans tuteur.',
   'Sunan Abu Daoud — Hadith n°2085 (Sahih)');

-- Q204 (moyen / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Khul'' en droit islamique ?', 'moyen', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un type de mariage temporaire',false,0),(q,'Le divorce à l''initiative de la femme en échange d''une compensation financière',true,1),(q,'La répudiation par le mari',false,2),(q,'Le mariage de convenance',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Khul'' est le droit de la femme de mettre fin au mariage en restituant la dot à son mari. C''est le pendant féminin du Talaq masculin.',
   'فَإِنْ خِفْتُمْ أَلَّا يُقِيمَا حُدُودَ اللَّهِ فَلَا جُنَاحَ عَلَيْهِمَا فِيمَا افْتَدَتْ بِهِ',
   'S''ils craignent de ne pas observer les limites d''Allah, il n''y a pas de péché à ce qu''elle se rachète.',
   'Sourate Al-Baqarah (2:229)');

-- Q205 (moyen / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Musharakah en finance islamique ?', 'moyen', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un prêt avec intérêt décroissant',false,0),(q,'Un contrat de partenariat où les profits et pertes sont partagés',true,1),(q,'Une assurance islamique',false,2),(q,'Un compte épargne islamique',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Musharakah est un partenariat islamique où deux parties apportent du capital et partagent profits et pertes proportionnellement. C''est une alternative islamique aux sociétés conventionnelles.',
   'وَإِنَّ كَثِيرًا مِّنَ الْخُلَطَاءِ لَيَبْغِي بَعْضُهُمْ عَلَىٰ بَعْضٍ إِلَّا الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ',
   'Certes, beaucoup d''associés font tort les uns aux autres, sauf ceux qui croient et font de bonnes œuvres.',
   'Sourate Sad (38:24)');

-- Q206 (moyen / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de prophètes et messagers Allah a-t-Il envoyés selon les hadiths ?', 'moyen', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'25 prophètes seulement',false,0),(q,'Environ 124 000 prophètes',true,1),(q,'1000 prophètes',false,2),(q,'313 messagers',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Prophète ﷺ a dit qu''Allah envoya 124 000 prophètes dont 315 messagers (selon un hadith). Le Coran mentionne 25 d''entre eux par leur nom.',
   'وَرُسُلًا قَدْ قَصَصْنَاهُمْ عَلَيْكَ مِن قَبْلُ وَرُسُلًا لَّمْ نَقْصُصْهُمْ عَلَيْكَ',
   'Des messagers dont Nous t''avons déjà raconté l''histoire, et des messagers dont Nous ne t''avons pas raconté l''histoire.',
   'Sourate An-Nisa (4:164)');

-- Q207 (moyen / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom du premier fils d''Ibrahim et qui est sa mère ?', 'moyen', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Ishaq, fils de Sarah',false,0),(q,'Ismail, fils de Hajar',true,1),(q,'Ya''qub, fils de Sarah',false,2),(q,'Lut, fils de Hajar',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Ismail est le premier fils d''Ibrahim, né de Hajar. Ibrahim les emmena dans le désert de La Mecque sur ordre d''Allah. Hajar trouva la source Zamzam et Ismail devint l''ancêtre des Arabes.',
   'رَبَّنَا إِنِّي أَسْكَنتُ مِن ذُرِّيَّتِي بِوَادٍ غَيْرِ ذِي زَرْعٍ عِندَ بَيْتِكَ الْمُحَرَّمِ',
   'Seigneur ! J''ai établi certains de mes descendants dans une vallée sans culture, près de Ta Sainte Maison.',
   'Sourate Ibrahim (14:37)');

-- Q208 (moyen / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le miracle le plus important des prophètes dans leurs propres communautés selon le Coran ?', 'moyen', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La résurrection des morts',false,0),(q,'Le Coran pour Muhammad ﷺ — miracle linguistique éternel',true,1),(q,'La guérison des maladies',false,2),(q,'La transformation du bâton en serpent',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Chaque prophète reçut des miracles adaptés à son époque. Le miracle du Prophète Muhammad ﷺ est le Coran — éternel, vérifiable à tout moment, défi lancé à l''humanité entière.',
   'وَقَالُوا لَوْلَا أُنزِلَ عَلَيْهِ آيَاتٌ مِّن رَّبِّهِ قُلْ إِنَّمَا الْآيَاتُ عِندَ اللَّهِ',
   'Ils disent : Pourquoi n''a-t-il pas reçu de miracles de son Seigneur ? Dis : Les miracles sont entre les mains d''Allah.',
   'Sourate Al-Ankabut (29:50)');

-- Q209 (moyen / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Mi''raj du Prophète Muhammad ﷺ ?', 'moyen', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La migration de La Mecque à Médine',false,0),(q,'Le voyage nocturne jusqu''à Jérusalem puis l''ascension aux Cieux',true,1),(q,'La révélation du Coran',false,2),(q,'La conquête de La Mecque',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''Isra'' (voyage nocturne à Jérusalem) et le Mi''raj (ascension aux Cieux) eurent lieu en une même nuit. Le Prophète ﷺ rencontra les prophètes et les 5 prières furent prescrites.',
   'سُبْحَانَ الَّذِي أَسْرَىٰ بِعَبْدِهِ لَيْلًا مِّنَ الْمَسْجِدِ الْحَرَامِ إِلَى الْمَسْجِدِ الْأَقْصَى',
   'Gloire à Celui qui a fait voyager de nuit Son serviteur depuis la Mosquée Sacrée jusqu''à la Mosquée Al-Aqsa.',
   'Sourate Al-Isra (17:1)');

-- Q210 (moyen / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quels sont les cinq prophètes "Ulul-Azm" (de la ferme résolution) ?', 'moyen', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Adam, Ibrahim, Moussa, Daoud, Issa',false,0),(q,'Nuh, Ibrahim, Moussa, Issa, Muhammad ﷺ',true,1),(q,'Ibrahim, Yunus, Yusuf, Moussa, Issa',false,2),(q,'Adam, Nuh, Ibrahim, Ismail, Muhammad ﷺ',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les 5 Ulul-Azm sont les prophètes qui reçurent une législation complète : Nuh (déluge), Ibrahim (monothéisme), Moussa (Torah), Issa (Injil), Muhammad ﷺ (Coran). Ils sont mentionnés ensemble dans le Coran.',
   'فَاصْبِرْ كَمَا صَبَرَ أُولُو الْعَزْمِ مِنَ الرُّسُلِ',
   'Sois patient comme ont été patients les messagers de ferme résolution.',
   'Sourate Al-Ahqaf (46:35)');

-- Q211 (moyen / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le don particulier du prophète Sulayman (Salomon) selon le Coran ?', 'moyen', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Il guérissait les malades',false,0),(q,'Il pouvait fendre les mers',false,1),(q,'Il comprenait le langage des animaux et commandait les djinns',true,2),(q,'Il transformait les pierres en or',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Sulayman comprenait le langage des oiseaux et des fourmis, commandait les djinns et les hommes, et le vent lui était soumis. C''est le prophète-roi par excellence dans le Coran.',
   'وَوَرِثَ سُلَيْمَانُ دَاوُودَ وَقَالَ يَا أَيُّهَا النَّاسُ عُلِّمْنَا مَنطِقَ الطَّيْرِ',
   'Sulayman hérita de Daoud et dit : Ô gens ! On nous a enseigné le langage des oiseaux.',
   'Sourate An-Naml (27:16)');

-- Q212 (moyen / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le miracle attribué au prophète Issa (Jésus) selon le Coran : parler dans le berceau ?', 'moyen', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'C''est une invention chrétienne absente du Coran',false,0),(q,'Oui, Issa parla dans son berceau pour défendre l''honneur de sa mère',true,1),(q,'C''est mentionné dans l''Injil seulement',false,2),(q,'Seulement selon les hadiths',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Coran affirme qu''Issa (Jésus) parla dans son berceau pour défendre sa mère Maryam accusée de fornication. Il se présenta comme serviteur d''Allah et prophète.',
   'قَالَ إِنِّي عَبْدُ اللَّهِ آتَانِيَ الْكِتَابَ وَجَعَلَنِي نَبِيًّا',
   'Il dit [dans le berceau] : Je suis le serviteur d''Allah. Il m''a donné le Livre et m''a fait prophète.',
   'Sourate Maryam (19:30)');

-- Q213 (moyen / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète est lié à la ville de Ninive (actuel Irak) ?', 'moyen', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Ibrahim (Abraham)',false,0),(q,'Hud',false,1),(q,'Yunus (Jonas)',true,2),(q,'Salih',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Yunus (Jonas) fut envoyé vers les habitants de Ninive. Il les quitta sans permission et fut avalé par la baleine. Après son sauvetage, il retourna vers son peuple qui crut en masse.',
   'وَأَرْسَلْنَاهُ إِلَىٰ مِائَةِ أَلْفٍ أَوْ يَزِيدُونَ فَآمَنُوا فَمَتَّعْنَاهُمْ إِلَىٰ حِينٍ',
   'Nous l''envoyâmes vers cent mille personnes ou davantage. Ils crurent et Nous les fîmes jouir jusqu''à un temps.',
   'Sourate As-Saffat (37:147-148)');

-- Q214 (moyen / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom de la femme du prophète Ibrahim qui fut la mère d''Ismail ?', 'moyen', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Sarah',false,0),(q,'Hajar (Hagar)',true,1),(q,'Maryam',false,2),(q,'Asiya',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Hajar fut l''épouse égyptienne d''Ibrahim et la mère d''Ismail. Ibrahim l''emmena dans le désert de La Mecque avec son bébé sur ordre d''Allah. Sa course entre Safa et Marwa est commémorée par le Sa''y.',
   'رَبَّنَا إِنِّي أَسْكَنتُ مِن ذُرِّيَّتِي بِوَادٍ غَيْرِ ذِي زَرْعٍ عِندَ بَيْتِكَ الْمُحَرَّمِ',
   'Seigneur ! J''ai établi certains de mes descendants dans une vallée sans culture, près de Ta Sainte Maison.',
   'Sourate Ibrahim (14:37)');

-- Q215 (moyen / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le vrai nom du prophète Dhul-Qarnayn mentionné dans le Coran ?', 'moyen', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Alexandre le Grand',false,0),(q,'Le roi Cyrus le Grand de Perse',false,1),(q,'Son identité exacte n''est pas connue — Allah seul sait',true,2),(q,'Le roi Salomon',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Dhul-Qarnayn est mentionné dans Al-Kahf (18:83-101). Il voyagea à l''Est et à l''Ouest et construisit une barrière contre Yajuj et Majuj. Son identité réelle est débattue par les savants.',
   'وَيَسْأَلُونَكَ عَن ذِي الْقَرْنَيْنِ قُلْ سَأَتْلُو عَلَيْكُم مِّنْهُ ذِكْرًا',
   'Ils t''interrogent sur Dhul-Qarnayn. Dis : Je vais vous en réciter quelque mention.',
   'Sourate Al-Kahf (18:83)');

-- Q216 (moyen / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Barzakh ?', 'moyen', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le Paradis des enfants',false,0),(q,'L''état intermédiaire entre la mort et la Résurrection',true,1),(q,'L''Enfer temporaire',false,2),(q,'Le lieu de rassemblement le Jour du Jugement',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Barzakh est la période entre la mort individuelle et la Résurrection générale. Les âmes y vivent une forme d''existence : les croyants dans une paix, les mécréants dans une punition.',
   'وَمِن وَرَائِهِم بَرْزَخٌ إِلَىٰ يَوْمِ يُبْعَثُونَ',
   'Devant eux s''étend un Barzakh jusqu''au Jour où ils seront ressuscités.',
   'Sourate Al-Mu''minun (23:100)');

-- Q217 (moyen / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Sirat selon la croyance islamique ?', 'moyen', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La voie droite de l''Islam',false,0),(q,'Le pont au-dessus de l''Enfer que traverseront tous les humains',true,1),(q,'La montagne de jugement',false,2),(q,'La porte du Paradis',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Sirat est un pont fin comme un cheveu tendu au-dessus de l''Enfer. Les croyants le traverseront à des vitesses différentes selon leurs actes. Les mécréants y tomberont.',
   'وَإِن مِّنكُمْ إِلَّا وَارِدُهَا كَانَ عَلَىٰ رَبِّكَ حَتْمًا مَّقْضِيًّا',
   'Il n''est pas un de vous qui ne doive y passer — c''est pour ton Seigneur une chose décrétée, inéluctable.',
   'Sourate Maryam (19:71)');

-- Q218 (moyen / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Fitna al-Qabr (épreuve du tombeau) ?', 'moyen', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le jugement final au Jour de la Résurrection',false,0),(q,'L''interrogatoire par les anges Munkar et Nakir dans la tombe',true,1),(q,'La punition des hypocrites',false,2),(q,'Le passage sur le pont Sirat',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Dans la tombe, deux anges (Munkar et Nakir) interrogent le défunt sur son Seigneur, sa religion et son prophète. Le croyant répond correctement et repose en paix jusqu''à la Résurrection.',
   'يُثَبِّتُ اللَّهُ الَّذِينَ آمَنُوا بِالْقَوْلِ الثَّابِتِ فِي الْحَيَاةِ الدُّنْيَا وَفِي الْآخِرَةِ',
   'Allah affermit ceux qui ont cru, par la parole ferme, dans la vie d''ici-bas et dans l''Au-delà.',
   'Sourate Ibrahim (14:27)');

-- Q219 (moyen / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Shafa''ah (intercession) du Prophète ﷺ ?', 'moyen', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La prière du Prophète ﷺ de son vivant pour ses compagnons',false,0),(q,'L''intercession accordée au Prophète ﷺ le Jour du Jugement pour sa communauté',true,1),(q,'La récitation du Coran au nom des morts',false,2),(q,'Le pardon automatique des péchés des croyants',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Shafa''ah al-Uzma est l''intercession suprême accordée au Prophète ﷺ le Jour du Jugement. Après la prière des autres prophètes, il intercèdera et Allah acceptera. C''est le Maqam Mahmud.',
   'عَسَىٰ أَن يَبْعَثَكَ رَبُّكَ مَقَامًا مَّحْمُودًا',
   'Ton Seigneur te ressuscitera à une station glorieuse.',
   'Sourate Al-Isra (17:79)');

-- Q220 (moyen / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quels sont les 4 niveaux du Qadar (destin) ?', 'moyen', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Foi, Prière, Jeûne, Zakat',false,0),(q,'Science (Ilm), Écriture (Kitabah), Volonté (Mashi''ah), Création (Khalq)',true,1),(q,'Naissance, Vie, Mort, Résurrection',false,2),(q,'Destin, Chance, Providence, Miracle',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les 4 niveaux du Qadar : 1) Ilm — Allah connaît tout éternellement ; 2) Kitabah — tout est écrit dans la Table Préservée ; 3) Mashi''ah — tout se produit par la Volonté d''Allah ; 4) Khalq — Allah crée tout.',
   'مَا أَصَابَ مِن مُّصِيبَةٍ فِي الْأَرْضِ وَلَا فِي أَنفُسِكُمْ إِلَّا فِي كِتَابٍ مِّن قَبْلِ أَن نَّبْرَأَهَا',
   'Aucune catastrophe ne frappe la terre ni vos personnes sans qu''elle soit dans un Livre, avant que Nous la créions.',
   'Sourate Al-Hadid (57:22)');

-- Q221 (moyen / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que les "Ashrat as-Sa''ah" (Signes de la Fin des Temps) ?', 'moyen', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Les 5 piliers de l''Islam',false,0),(q,'Les 6 piliers de la foi',false,1),(q,'Les signes précédant le Jour du Jugement',true,2),(q,'Les prophéties sur l''avenir des nations',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les signes de la Fin sont divisés en petits signes (déjà accomplis ou en cours) et grands signes (à venir) : apparition du Mahdi, Issa reviendra, Dajjal, Yajuj et Majuj, lever du soleil à l''Ouest, etc.',
   'فَهَلْ يَنظُرُونَ إِلَّا السَّاعَةَ أَن تَأْتِيَهُم بَغْتَةً فَقَدْ جَاءَ أَشْرَاطُهَا',
   'N''attendent-ils que l''Heure qui viendra soudainement ? Ses signes précurseurs sont déjà venus.',
   'Sourate Muhammad (47:18)');

-- Q222 (moyen / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Tawakkul (confiance en Allah) selon l''Islam ?', 'moyen', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Ne rien faire et attendre qu''Allah arrange tout',false,0),(q,'Prendre les moyens nécessaires puis remettre le résultat à Allah avec confiance totale',true,1),(q,'Réciter des invocations plutôt que de travailler',false,2),(q,'Accepter passivement tout ce qui arrive',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Tawakkul n''est pas la passivité. Le Prophète ﷺ dit à quelqu''un qui laissait sa chamelle sans l''attacher : "Attache-la, puis mets ta confiance en Allah."',
   'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
   'Et quiconque place sa confiance en Allah, Il lui suffit.',
   'Sourate At-Talaq (65:3)');

-- Q223 (moyen / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Dhikr (invocation) en Islam ?', 'moyen', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La récitation du Coran uniquement',false,0),(q,'Le souvenir et la mention d''Allah par la langue et le cœur',true,1),(q,'La prière facultative',false,2),(q,'L''enseignement islamique',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Dhikr est l''une des meilleures adorations. Le Prophète ﷺ a dit que les assemblées de Dhikr sont des jardins du Paradis. Il apaise le cœur et rapproche d''Allah.',
   'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
   'C''est par le souvenir d''Allah que les cœurs se tranquillisent.',
   'Sourate Ar-Ra''d (13:28)');

-- Q224 (moyen / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Sabr (patience) selon l''Islam ?', 'moyen', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Accepter passivement toute injustice',false,0),(q,'La maîtrise de soi et la persévérance face aux épreuves, en gardant sa foi',true,1),(q,'Le jeûne expiatoire',false,2),(q,'L''abstention totale de plainte',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Sabr est une vertu centrale de l''Islam. Allah est avec les patients et leur promet une récompense sans limites. Il s''applique lors des épreuves, dans l''obéissance et face aux tentations.',
   'إِنَّمَا يُوَفَّى الصَّابِرُونَ أَجْرَهُم بِغَيْرِ حِسَابٍ',
   'Les patients recevront leur récompense sans compte.',
   'Sourate Az-Zumar (39:10)');

-- Q225 (moyen / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Que sont les anges Kiraman Katibin ?', 'moyen', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Les anges gardiens de l''Enfer',false,0),(q,'Les anges qui soufflent dans la Trompette',false,1),(q,'Les deux anges nobles qui enregistrent les actes de chaque personne',true,2),(q,'Les anges qui descendent la nuit du Destin',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les Kiraman Katibin (Nobles Scribes) sont deux anges affectés à chaque personne : l''un à droite note les bonnes actions, l''un à gauche note les mauvaises. Ils sont toujours présents.',
   'وَإِنَّ عَلَيْكُمْ لَحَافِظِينَ كِرَامًا كَاتِبِينَ يَعْلَمُونَ مَا تَفْعَلُونَ',
   'Des gardiens sont en effet établis sur vous — nobles et scribes — ils savent ce que vous faites.',
   'Sourate Al-Infitar (82:10-12)');

-- Lot 3a : difficile piliers + coran + hadith (Q226-Q270)

-- Q226 (difficile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Hajj Mabrur et quelle est sa récompense ?', 'difficile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un Hajj effectué deux fois — récompense : Umra gratuite',false,0),(q,'Un Hajj accompli selon les règles sans péchés — récompense : le Paradis',true,1),(q,'Un Hajj avec guide officiel — récompense : pardon complet',false,2),(q,'Un Hajj accompli en famille — récompense : double récompense',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Hajj Mabrur est un Hajj agréé par Allah, accompli correctement et sans péché. Le Prophète ﷺ a dit que sa seule récompense est le Paradis.',
   'الْحَجُّ الْمَبْرُورُ لَيْسَ لَهُ جَزَاءٌ إِلَّا الْجَنَّةُ',
   'Pour le Hajj Mabrur, il n''y a pas d''autre récompense que le Paradis.',
   'Sahih Bukhari — Hadith n°1773');

-- Q227 (difficile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quels sont les cinq Mawaqit (points d''Ihram) géographiques pour le Hajj ?', 'difficile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La Mecque, Médine, Jeddah, Taïf, Riyadh',false,0),(q,'Dhul-Hulaifah, Al-Juhfah, Qarn al-Manazil, Yalamlam, Dhat Irq',true,1),(q,'Mina, Arafat, Muzdalifah, Safa, Marwa',false,2),(q,'Masjid al-Haram, Masjid an-Nabawi, Masjid al-Aqsa, Masjid Quba, Masjid al-Qiblatayn',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les 5 Mawaqit : Dhul-Hulaifah (pour les gens de Médine), Al-Juhfah (pour les gens de Syrie/Afrique du Nord), Qarn al-Manazil (pour les gens de Najd), Yalamlam (pour les gens du Yémen), Dhat Irq (pour les gens d''Irak).',
   'وَقِّتَ لِأَهْلِ الْمَدِينَةِ ذَا الْحُلَيْفَةِ وَلِأَهْلِ الشَّأْمِ الْجُحْفَةَ',
   'Il fixa Dhul-Hulaifah pour les gens de Médine et Al-Juhfah pour les gens de Syrie.',
   'Sahih Bukhari — Hadith n°1522');

-- Q228 (difficile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est la Kaffarah (expiation) pour une relation conjugale délibérée pendant le Ramadan ?', 'difficile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Uniquement un jeûne de 2 mois',false,0),(q,'Libérer un esclave, OU jeûner 2 mois consécutifs, OU nourrir 60 pauvres (dans cet ordre)',true,1),(q,'Payer une amende à l''imam',false,2),(q,'Faire une Umra pour expiation',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''expiation (Kaffarah) pour une relation conjugale délibérée pendant le Ramadan est très sévère car elle suit un ordre strict : d''abord libérer un esclave, sinon jeûner 2 mois de suite, sinon nourrir 60 pauvres.',
   'أَعْتِقْ رَقَبَةً قَالَ لَا أَجِدُ قَالَ فَصُمْ شَهْرَيْنِ مُتَتَابِعَيْنِ',
   'Affranchis un esclave. Il dit : Je n''en ai pas. Il dit : Jeûne deux mois consécutifs.',
   'Sahih Bukhari — Hadith n°1936');

-- Q229 (difficile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est la Zakat sur les cultures et récoltes selon la jurisprudence islamique ?', 'difficile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'2,5% sur toutes les récoltes',false,0),(q,'10% si irrigué naturellement (pluie), 5% si irrigué artificiellement',true,1),(q,'20% de la récolte',false,2),(q,'La Zakat ne s''applique pas aux récoltes',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Zakat agricole (''Ushr) : 10% si la culture est irriguée par la pluie ou l''eau courante naturelle, et 5% si irriguée artificiellement (pompe, arrosage). Cette différence tient compte des frais de production.',
   'فِيمَا سَقَتِ السَّمَاءُ وَالْعُيُونُ أَوْ كَانَ عَثَرِيًّا الْعُشْرُ وَمَا سُقِيَ بِالنَّضْحِ نِصْفُ الْعُشْرِ',
   'Sur ce qu''arrosent le ciel et les sources, ou ce qui est irrigué naturellement : le dixième. Sur ce qu''on arrose avec effort : la moitié du dixième.',
   'Sahih Bukhari — Hadith n°1483');

-- Q230 (difficile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la prière du Duha et combien de rak''aat peut-elle avoir ?', 'difficile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Prière du vendredi matin — 2 rak''aat',false,0),(q,'Prière du milieu de la matinée — minimum 2, maximum 8 rak''aat selon la Sunna',true,1),(q,'Prière après le Fajr — 2 rak''aat uniquement',false,2),(q,'Prière de la nuit — 4 rak''aat',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La prière du Duha (Salat al-Ishraq ou Salat al-Duha) se prie entre le lever du soleil et le zénith. Elle vaut la récompense d''une Sadaqa pour chaque articulation du corps.',
   'صَلَاةُ الضُّحَى رَكْعَتَانِ وَمَنْ شَاءَ صَلَّى أَكْثَرَ',
   'La prière du Duha est de deux rak''aat. Qui veut peut en prier davantage.',
   'Musnad Ahmad — Hadith authentifié');

-- Q231 (difficile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le Hawl (délai) requis pour que la Zakat soit due ?', 'difficile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'6 mois après que la richesse atteint le Nisab',false,0),(q,'Un an lunaire complet (environ 354 jours) après que la richesse atteint le Nisab',true,1),(q,'1 an solaire (365 jours)',false,2),(q,'Dès que la richesse atteint le Nisab',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Hawl est la condition temporelle : la richesse doit avoir atteint le Nisab et être demeurée à ce niveau pendant toute une année lunaire pour que la Zakat soit obligatoire.',
   'لَا زَكَاةَ فِي مَالٍ حَتَّى يَحُولَ عَلَيْهِ الْحَوْلُ',
   'Il n''y a pas de Zakat sur un bien tant qu''une année ne s''est pas écoulée sur lui.',
   'Sunan at-Tirmidhi — Hadith n°631 (Hasan)');

-- Q232 (difficile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Ramy al-Jamarat — combien de cailloux au total lors d''un Hajj de 3 jours à Mina ?', 'difficile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'21 cailloux (7 par jour)',false,0),(q,'49 cailloux (7+21+21)',true,1),(q,'70 cailloux (7 par stèle × 10 jours)',false,2),(q,'21 cailloux (7 pour la grande stèle seulement)',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le 10 Dhul-Hijja : 7 cailloux sur la grande stèle seulement. Les 11 et 12 (ou 13) : 7 cailloux sur chacune des 3 stèles = 21/jour. Total pour 3 jours à Mina : 7+21+21 = 49 cailloux.',
   'وَاذْكُرُوا اللَّهَ فِي أَيَّامٍ مَّعْدُودَاتٍ',
   'Rappelez-vous Allah pendant les jours comptés.',
   'Sourate Al-Baqarah (2:203)');

-- Q233 (difficile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Zakat al-Fitr en termes de quantité et de moment de versement ?', 'difficile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un montant en argent calculé selon le salaire, versé le jour de l''Aïd',false,0),(q,'1 Sa'' (environ 3 kg) de nourriture de base, versée avant la prière de l''Aïd al-Fitr',true,1),(q,'2,5% des économies, versés à la fin du Ramadan',false,2),(q,'Un repas offert à un pauvre le soir de l''Aïd',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Zakat al-Fitr est de 1 Sa'' (mesure ancienne ≈ 2,5 à 3 kg) de nourriture de base (dattes, orge, raisins secs, fromage). Elle doit être versée avant la prière de l''Aïd pour être acceptée.',
   'فَرَضَ رَسُولُ اللَّهِ ﷺ زَكَاةَ الْفِطْرِ صَاعًا مِنْ تَمْرٍ أَوْ صَاعًا مِنْ شَعِيرٍ',
   'Le Messager d''Allah ﷺ a prescrit la Zakat al-Fitr : un Sa'' de dattes ou un Sa'' d''orge.',
   'Sahih Bukhari — Hadith n°1503');

-- Q234 (difficile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Tahajjud et à quel moment doit-il idéalement être accompli ?', 'difficile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Prière accomplie après le Isha sans se coucher',false,0),(q,'Prière accomplie après s''être éveillé du sommeil, de préférence dans le dernier tiers de la nuit',true,1),(q,'Prière de la première partie de la nuit (entre Maghrib et Isha)',false,2),(q,'Prière accomplie juste avant le Fajr',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Tahajjud est la prière de nuit accomplie après un sommeil. Le meilleur moment est le dernier tiers de la nuit quand Allah descend au ciel du monde et dit : "Qui M''invoque pour que Je lui réponde ?"',
   'وَمِنَ اللَّيْلِ فَتَهَجَّدْ بِهِ نَافِلَةً لَّكَ عَسَىٰ أَن يَبْعَثَكَ رَبُّكَ مَقَامًا مَّحْمُودًا',
   'Et pendant la nuit, accomplis la prière du Tahajjud, en surérogatoire pour toi. Peut-être ton Seigneur t''élèvera-t-Il à une station glorieuse.',
   'Sourate Al-Isra (17:79)');

-- Q235 (difficile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que l''Istita''a (capacité) comme condition du Hajj ?', 'difficile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Uniquement avoir l''argent pour le voyage',false,0),(q,'Être physiquement et financièrement capable sans mettre sa famille en danger financier',true,1),(q,'Être âgé de moins de 60 ans',false,2),(q,'Avoir déjà fait l''Umra',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''Istita''a comprend : la capacité financière (inclut les frais + provisions pour la famille), la santé physique, la sécurité du chemin, et pour la femme : la présence d''un Mahram.',
   'وَلِلَّهِ عَلَى النَّاسِ حِجُّ الْبَيْتِ مَنِ اسْتَطَاعَ إِلَيْهِ سَبِيلًا',
   'C''est un devoir envers Allah pour les hommes de faire le pèlerinage, pour celui qui peut y trouver un chemin.',
   'Sourate Aal-Imran (3:97)');

-- Q236 (difficile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le "Nasikh wal-Mansukh" dans les sciences coraniques ?', 'difficile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La distinction entre les sourates mecquoises et médinoises',false,0),(q,'L''abrogation : certains versets ont abrogé d''autres versets antérieurs',true,1),(q,'La traduction du Coran en langues étrangères',false,2),(q,'Les versets qui se répètent dans le Coran',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Nasikh (abrogeant) et le Mansukh (abrogé) désignent les versets dont la règle juridique a été remplacée par un verset ultérieur. Ex : la direction de prière changée de Jérusalem vers La Mecque.',
   'مَا نَنسَخْ مِنْ آيَةٍ أَوْ نُنسِهَا نَأْتِ بِخَيْرٍ مِّنْهَا أَوْ مِثْلِهَا',
   'Lorsque Nous abrogeons un verset ou le faisons oublier, Nous en apportons un meilleur ou un semblable.',
   'Sourate Al-Baqarah (2:106)');

-- Q237 (difficile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que les versets "Muhkam" et "Mutashabih" dans le Coran ?', 'difficile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Les sourates longues (Muhkam) et courtes (Mutashabih)',false,0),(q,'Les versets de sens clair et précis (Muhkam) et les versets au sens ambigu nécessitant interprétation (Mutashabih)',true,1),(q,'Les versets révélés à La Mecque et à Médine',false,2),(q,'Les versets abrogés et les versets abrogeants',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les Muhkam sont les versets clairs dont le sens est univoque — la majorité du Coran. Les Mutashabih sont les versets dont le sens est ambigu. Les pieux s''y soumettent sans tenter de les déformer.',
   'مِنْهُ آيَاتٌ مُّحْكَمَاتٌ هُنَّ أُمُّ الْكِتَابِ وَأُخَرُ مُتَشَابِهَاتٌ',
   'Il y a parmi ses versets des Muhkam — qui sont la base du Livre — et d''autres Mutashabih.',
   'Sourate Aal-Imran (3:7)');

-- Q238 (difficile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom exact de la science étudiant les circonstances de révélation des versets ?', 'difficile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'At-Tafsir',false,0),(q,'Asbab an-Nuzul (Causes de la révélation)',true,1),(q,'Al-Ijaz',false,2),(q,'An-Nasikh wal-Mansukh',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les Asbab an-Nuzul (causes de la révélation) expliquent dans quel contexte chaque verset fut révélé. Cette science est essentielle pour comprendre la signification et la portée exacte des versets.',
   'إِنَّا أَنزَلْنَاهُ فِي لَيْلَةِ الْقَدْرِ',
   'Nous l''avons fait descendre pendant la nuit du Destin.',
   'Sourate Al-Qadr (97:1)');

-- Q239 (difficile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Tafsir Bil-Ma''thur ?', 'difficile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'L''interprétation du Coran par l''opinion personnelle',false,0),(q,'L''interprétation du Coran par le Coran lui-même, la Sunna et les propos des Compagnons',true,1),(q,'La traduction littérale du Coran',false,2),(q,'L''interprétation mystique (soufie) du Coran',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Tafsir Bil-Ma''thur est la méthode la plus fiable : expliquer le Coran par le Coran (un verset en éclaire un autre), puis par la Sunna, puis par les propos des Compagnons et leurs successeurs.',
   'أَفَلَا يَتَدَبَّرُونَ الْقُرْآنَ',
   'Ne méditent-ils pas le Coran ?',
   'Sourate An-Nisa (4:82)');

-- Q240 (difficile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Combien de sourates du Coran ne contiennent pas la lettre "Fa" ?', 'difficile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Toutes les sourates contiennent toutes les lettres arabes',false,0),(q,'La sourate Al-Asr est la seule à ne pas contenir toutes les lettres arabes',false,1),(q,'Certaines courtes sourates ne contiennent pas toutes les lettres — c''est une caractéristique normale',true,2),(q,'Il n''y a aucune lettre manquante dans le Coran',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les courtes sourates du Coran n''utilisent pas forcément toutes les lettres arabes. Les lettres Muqatta''at au début de certaines sourates représentent un défi linguistique dont le sens complet est connu d''Allah seul.',
   'وَلَقَدْ يَسَّرْنَا الْقُرْآنَ لِلذِّكْرِ فَهَلْ مِن مُّدَّكِرٍ',
   'Nous avons facilité le Coran pour qu''on le rappelle. Y a-t-il quelqu''un pour s''en souvenir ?',
   'Sourate Al-Qamar (54:17)');

-- Q241 (difficile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est la différence entre un verset révélé "layla" (nuit) et "nahara" (jour) dans les sciences du Coran ?', 'difficile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Il n''y a pas de distinction dans les sciences coraniques',false,0),(q,'Les savants ont identifié les contextes temporels de révélation dans la science des Asbab an-Nuzul',true,1),(q,'Les versets révélés la nuit sont plus importants',false,2),(q,'Seuls les versets révélés la nuit sont authentiques',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La science des Asbab an-Nuzul documente le moment et le contexte de révélation de chaque verset — de nuit, de jour, en voyage, en paix ou en guerre. La Laylat al-Qadr en est l''exemple suprême.',
   'وَقُرْآنَ الْفَجْرِ إِنَّ قُرْآنَ الْفَجْرِ كَانَ مَشْهُودًا',
   'Et la récitation à l''aube — car la récitation de l''aube est attestée.',
   'Sourate Al-Isra (17:78)');

-- Q242 (difficile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que l''"Ijaz al-Ilmi" (inimitabilité scientifique) du Coran ?', 'difficile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La perfection grammaticale du Coran en arabe',false,0),(q,'Des données coraniques conformes aux découvertes scientifiques modernes qui corroborent son origine divine',true,1),(q,'La difficulté de mémoriser le Coran',false,2),(q,'L''impossibilité de produire une traduction parfaite',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''Ijaz al-Ilmi désigne les passages coraniques concordant avec des découvertes scientifiques modernes : développement embryonnaire, expansion de l''univers, barrières entre les mers, etc.',
   'سَنُرِيهِمْ آيَاتِنَا فِي الْآفَاقِ وَفِي أَنفُسِهِمْ حَتَّىٰ يَتَبَيَّنَ لَهُمْ أَنَّهُ الْحَقُّ',
   'Nous leur montrerons Nos signes dans l''univers et en eux-mêmes, jusqu''à ce qu''il leur soit clair que c''est la Vérité.',
   'Sourate Fussilat (41:53)');

-- Q243 (difficile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel savant a écrit le plus célèbre Tafsir classique — Jami'' al-Bayan ?', 'difficile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'L''imam Ibn Kathir',false,0),(q,'L''imam Al-Qurtubi',false,1),(q,'L''imam Abu Ja''far at-Tabari',true,2),(q,'L''imam As-Suyuti',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''imam Muhammad ibn Jarir at-Tabari (m. 923) écrivit le Jami'' al-Bayan fi Ta''wil al-Quran, le premier grand Tafsir encyclopédique. Ibn Khaldun le considérait comme le Tafsir le plus complet.',
   'أَفَلَمْ يَدَّبَّرُوا الْقَوْلَ',
   'N''ont-ils pas médité la Parole ?',
   'Sourate Al-Mu''minun (23:68)');

-- Q244 (difficile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la sourate Al-Fatiha contient comme types de demandes à Allah ?', 'difficile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Uniquement des louanges d''Allah',false,0),(q,'Des louanges, une déclaration d''adoration et une demande de guidance',true,1),(q,'Uniquement des demandes de pardon',false,2),(q,'Des demandes de protection contre Satan uniquement',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Al-Fatiha est un dialogue entre Allah et Son serviteur : v.1-4 = louanges d''Allah ; v.5 = déclaration d''adoration exclusive (Tawhid) ; v.6-7 = demande de guidance vers le droit chemin.',
   'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ',
   'Guide-nous dans le droit chemin, le chemin de ceux que Tu as comblés de bienfaits.',
   'Sourate Al-Fatiha (1:6-7)');

-- Q245 (difficile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que les "As-Sab'' at-Tiwal" (Les Sept Longues) dans la classification des sourates ?', 'difficile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Les 7 premiers versets du Coran',false,0),(q,'Al-Fatiha répétée 7 fois dans les prières',false,1),(q,'Les 7 plus longues sourates du Coran commençant par Al-Baqarah',true,2),(q,'Les 7 sourates récitées le vendredi',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les As-Sab'' at-Tiwal sont : Al-Baqarah, Aal-Imran, An-Nisa, Al-Ma''idah, Al-An''am, Al-A''raf, et la 7ème est Al-Anfal+At-Tawbah (considérées comme une). Ce sont les sourates les plus longues du Coran.',
   'وَلَقَدْ آتَيْنَاكَ سَبْعًا مِّنَ الْمَثَانِي وَالْقُرْآنَ الْعَظِيمَ',
   'Nous t''avons donné les sept qui se répètent et le Coran Immense.',
   'Sourate Al-Hijr (15:87)');

-- Q246 (difficile / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce qu''un Hadith Mursal et pourquoi est-il moins fiable ?', 'difficile', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un hadith transmis par beaucoup de personnes',false,0),(q,'Un hadith dont un Compagnon du Prophète ﷺ est omis de la chaîne',true,1),(q,'Un hadith avec un texte douteux',false,2),(q,'Un hadith compilé après le 3ème siècle islamique',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Un Hadith Mursal est un hadith où un Successeur (Tabi''i) cite directement le Prophète ﷺ sans mentionner le Compagnon intermédiaire. La chaîne est donc incomplète et son authenticité est débattue.',
   'فَلْيَحْذَرِ الَّذِينَ يُخَالِفُونَ عَنْ أَمْرِهِ',
   'Que ceux qui s''opposent à son ordre prennent garde.',
   'Sourate An-Nur (24:63)');

-- Q247 (difficile / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le hadith "Arba''in" (Quarante hadiths) et qui l''a compilé ?', 'difficile', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un recueil de l''imam Bukhari',false,0),(q,'Un recueil célèbre de 42 hadiths fondamentaux compilé par l''imam An-Nawawi',true,1),(q,'Les 40 premiers hadiths du Sahih Muslim',false,2),(q,'Un recueil de l''imam Ahmad',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les Arba''in An-Nawawiyyah sont 42 hadiths fondamentaux compilés par l''imam Yahya ibn Sharaf An-Nawawi (m. 1277). Ils couvrent les piliers de la foi, de la loi et de la spiritualité islamique.',
   'مَنْ حَفِظَ عَلَى أُمَّتِي أَرْبَعِينَ حَدِيثًا مِنْ أَمْرِ دِينِهَا بَعَثَهُ اللَّهُ يَوْمَ الْقِيَامَةِ',
   'Celui qui préserve pour ma communauté quarante hadiths concernant sa religion, Allah le ressuscitera savant.',
   'Cité dans la Muqaddimah des Arba''in An-Nawawiyyah');

-- Q248 (difficile / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la science du "''Ilal al-Hadith" (défauts cachés des hadiths) ?', 'difficile', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'L''étude des transmetteurs menteurs',false,0),(q,'La détection de défauts cachés qui compromettent l''authenticité d''un hadith malgré une chaîne apparemment correcte',true,1),(q,'L''étude des contradictions entre hadiths',false,2),(q,'L''évaluation de la mémorisation des transmetteurs',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La science des ''Ilal (défauts) identifie des problèmes cachés dans un hadith : insertion d''un nom dans une chaîne, confusion entre noms similaires, attribution erronée. C''est la science la plus difficile du hadith.',
   'إِنَّ هَذَا الْعِلْمَ دِينٌ فَانْظُرُوا عَمَّنْ تَأْخُذُونَ دِينَكُمْ',
   'Cette connaissance est une religion, regardez donc de qui vous prenez votre religion.',
   'Muqaddimah Sahih Muslim');

-- Q249 (difficile / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le statut du hadith "Da''if" (faible) dans la jurisprudence islamique ?', 'difficile', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Complètement rejeté par tous les savants',false,0),(q,'Accepté comme Sahih si deux savants le confirment',false,1),(q,'Débattu : certains savants l''acceptent pour les vertus (Fada''il) avec conditions strictes, mais pas pour les règles juridiques',true,2),(q,'Accepté si le texte n''est pas trop différent des hadiths Sahih',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Selon l''imam Ahmad et d''autres, le Hadith Da''if peut être utilisé pour les Fada''il al-A''mal (vertus des actes) à condition : ne pas être très faible, avoir un fondement général dans la Sharia et l''utiliser avec précaution.',
   'وَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍ خَيْرًا يَرَهُ',
   'Quiconque fait le poids d''un atome de bien le verra.',
   'Sourate Al-Zalzalah (99:7)');

-- Q250 (difficile / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce qu''un hadith "Mu''all" et en quoi diffère-t-il du "Mudallas" ?', 'difficile', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Ce sont deux termes synonymes désignant les hadiths faibles',false,0),(q,'Le Mu''all a un défaut caché dans la chaîne ou le texte ; le Mudallas présente délibérément la chaîne de façon trompeuse',true,1),(q,'Le Mu''all est un hadith Sahih et le Mudallas est un hadith Hasan',false,2),(q,'Les deux sont des hadiths falsifiés par des transmetteurs malhonnêtes',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Mu''all al-Hadith a un défaut caché difficile à détecter (insertion, confusion). Le Mudallas est une présentation trompeuse : le transmetteur prétend avoir entendu directement quelqu''un qu''il n''a pas entendu.',
   'يَا أَيُّهَا الَّذِينَ آمَنُوا كُونُوا قَوَّامِينَ بِالْقِسْطِ شُهَدَاءَ لِلَّهِ',
   'Ô croyants ! Soyez rigoureux pour la justice, témoignant pour Allah.',
   'Sourate An-Nisa (4:135)');

-- Lot 3b : difficile histoire + jurisprudence (Q251-Q295)

-- Q251 (difficile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la "Jahiliyyah" et quelle était la religion des Arabes avant l''Islam ?', 'difficile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Les Arabes étaient tous juifs et chrétiens',false,0),(q,'La Jahiliyyah était la période d''ignorance pré-islamique : polythéisme, infanticide des filles, tribalisme',true,1),(q,'Les Arabes suivaient la religion d''Ibrahim sans déviations',false,2),(q,'Les Arabes n''avaient aucune religion organisée',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Jahiliyyah (ignorance) désigne l''état spirituel et moral de l''Arabie pré-islamique : 360 idoles autour de la Kaaba, infanticide des filles, esclavage, tribalisme. L''Islam abolit ces pratiques.',
   'وَكُنتُمْ عَلَىٰ شَفَا حُفْرَةٍ مِّنَ النَّارِ فَأَنقَذَكُم مِّنْهَا',
   'Vous étiez au bord d''un gouffre de feu, Il vous en a sauvés.',
   'Sourate Aal-Imran (3:103)');

-- Q252 (difficile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel était le rôle et la signification du "Dar al-Arqam" dans les premières années de l''Islam ?', 'difficile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le palais du Prophète ﷺ à Médine',false,0),(q,'La première école islamique à La Mecque où le Prophète ﷺ enseignait discrètement',true,1),(q,'La mosquée construite par Khadijah',false,2),(q,'Le lieu de compilation du Coran',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Dar al-Arqam était la maison d''al-Arqam ibn Abi al-Arqam où le Prophète ﷺ enseignait secrètement les premiers musulmans. C''est là qu''Umar ibn al-Khattab embrassa l''Islam.',
   'يَا أَيُّهَا الرَّسُولُ بَلِّغْ مَا أُنزِلَ إِلَيْكَ مِن رَّبِّكَ',
   'Ô Messager ! Transmets ce qui t''a été révélé par ton Seigneur.',
   'Sourate Al-Ma''idah (5:67)');

-- Q253 (difficile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la bataille de Yarmouk (636) et quelle fut son importance ?', 'difficile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Victoire des Perses sur les musulmans',false,0),(q,'Victoire décisive des musulmans sur l''armée byzantine qui ouvrit la Syrie et la Palestine à l''Islam',true,1),(q,'Défaite des musulmans contre les Byzantins',false,2),(q,'Bataille entre muslims et Quraychites',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La bataille de Yarmouk (636 ap. J.-C.), menée par Khalid ibn al-Walid, fut une victoire décisive sur l''armée byzantine. Elle mit fin à la domination byzantine en Syrie-Palestine et ouvrit ces régions à l''Islam.',
   'وَلَيَنصُرَنَّ اللَّهُ مَن يَنصُرُهُ إِنَّ اللَّهَ لَقَوِيٌّ عَزِيزٌ',
   'Allah aide certes ceux qui l''aident. Allah est Puissant et Glorieux.',
   'Sourate Al-Hajj (22:40)');

-- Q254 (difficile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel était le système de Calligraphie arabe utilisé pour écrire le Coran à l''époque des Compagnons, et qu''est-ce qui manquait ?', 'difficile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le système de calligraphie Naskhi complet avec tous les signes diacritiques',false,0),(q,'Le Rasm al-Uthmani sans points diacritiques (I''jam) ni voyelles (Tashkil) initialement',true,1),(q,'Le système Kufi avec des voyelles complètes',false,2),(q,'La calligraphie Thuluth avec des points mais sans voyelles',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Coran d''Uthman fut écrit en Rasm uthmani sans points diacritiques ni voyelles. Les points (I''jam) furent ajoutés par Abu al-Aswad al-Du''ali sous Mu''awiya, et les voyelles (Tashkil) plus tard par Al-Khalil ibn Ahmad.',
   'إِنَّا نَحْنُ نَزَّلْنَا الذِّكْرَ وَإِنَّا لَهُ لَحَافِظُونَ',
   'C''est Nous qui avons fait descendre le Rappel et Nous en sommes les gardiens.',
   'Sourate Al-Hijr (15:9)');

-- Q255 (difficile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qui était Ibn Khaldun et quelle est son importance dans l''histoire islamique ?', 'difficile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un imam et juriste du 13ème siècle',false,0),(q,'Le philosophe et historien du 14ème siècle considéré comme le père de la sociologie et de la philosophie de l''histoire',true,1),(q,'Un calife de la dynastie abbasside',false,2),(q,'Un explorateur musulman qui voyagea au Mexique',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Abd ar-Rahman ibn Khaldun (1332-1406) écrivit la Muqaddimah (Introduction), premier ouvrage systématique de philosophie de l''histoire et de sociologie. Il développa le concept de ''Asabiyyah (cohésion sociale).',
   'إِنَّ اللَّهَ لَا يُغَيِّرُ مَا بِقَوْمٍ حَتَّىٰ يُغَيِّرُوا مَا بِأَنفُسِهِمْ',
   'Allah ne change pas ce qu''il y a pour un peuple tant que ce peuple ne change pas ce qu''il y a en lui-même.',
   'Sourate Ar-Ra''d (13:11)');

-- Q256 (difficile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''était Al-Andalus et quelle fut sa durée dans l''histoire islamique ?', 'difficile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Une région d''Afrique du Nord sous domination islamique (700-900)',false,0),(q,'La péninsule ibérique (Espagne/Portugal) sous domination islamique de 711 à 1492',true,1),(q,'L''empire byzantin converti à l''Islam',false,2),(q,'La région de l''actuelle Turquie islamique',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Al-Andalus fut la domination islamique en péninsule ibérique de 711 (conquête de Tariq ibn Ziyad) à 1492 (chute de Grenade). Elle connut un âge d''or de sciences, philosophie et culture.',
   'فَسِيرُوا فِي الْأَرْضِ فَانظُرُوا كَيْفَ كَانَ عَاقِبَةُ الْمُكَذِّبِينَ',
   'Parcourez la terre et regardez ce qu''il est advenu de ceux qui niaient.',
   'Sourate Aal-Imran (3:137)');

-- Q257 (difficile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel fut l''impact de la bataille d''Ain Jalut (1260) dans l''histoire islamique ?', 'difficile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La conquête musulmane de l''Inde',false,0),(q,'La première grande défaite des Mongols par les Mamelouks, stoppant leur avancée en terre islamique',true,1),(q,'La reconquête de Jérusalem par Saladin',false,2),(q,'La chute de Constantinople',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La bataille d''Ain Jalut (1260) en Palestine vit les Mamelouks d''Égypte, menés par Baybars, écraser les Mongols. Ce fut la première défaite mongole et elle sauva l''Égypte, l''Afrique du Nord et peut-être l''Islam occidental.',
   'كَمْ مِنْ فِئَةٍ قَلِيلَةٍ غَلَبَتْ فِئَةً كَثِيرَةً بِإِذْنِ اللَّهِ',
   'Combien de fois une petite troupe a vaincu une grande troupe par la permission d''Allah.',
   'Sourate Al-Baqarah (2:249)');

-- Q258 (difficile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qui était Tariq ibn Ziyad et quelle fut sa contribution historique ?', 'difficile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le général qui conquit la Perse',false,0),(q,'Le général berbère qui mena la conquête islamique de l''Espagne en 711',true,1),(q,'Le premier gouverneur musulman d''Égypte',false,2),(q,'Le commandant de la bataille de Yarmouk',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Tariq ibn Ziyad traversa le détroit en 711 avec 7000 hommes et vainquit le roi Rodéric. Le rocher qu''il escalada porte son nom : Jabal Tariq (Gibraltar — "la montagne de Tariq").',
   'وَلَيَنصُرَنَّ اللَّهُ مَن يَنصُرُهُ',
   'Allah aide certes ceux qui L''aident.',
   'Sourate Al-Hajj (22:40)');

-- Q259 (difficile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la "Fitna al-Kubra" (Grande Discorde) dans l''histoire islamique ?', 'difficile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La persécution des musulmans à La Mecque',false,0),(q,'Les guerres civiles islamiques suite à l''assassinat du calife Uthman jusqu''à l''arbitrage entre Ali et Mu''awiya',true,1),(q,'L''invasion des Croisés à Jérusalem',false,2),(q,'La chute du califat abbasside sous les Mongols',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Grande Discorde (al-Fitna al-Kubra) commença avec l''assassinat du calife Uthman (656), puis la bataille du Chameau entre Ali et Aïcha, puis Siffin entre Ali et Mu''awiya, menant à la division de l''Umma.',
   'وَاعْتَصِمُوا بِحَبْلِ اللَّهِ جَمِيعًا وَلَا تَفَرَّقُوا',
   'Tenez-vous tous ensemble au câble d''Allah et ne vous divisez pas.',
   'Sourate Aal-Imran (3:103)');

-- Q260 (difficile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qui fut Salah ad-Din al-Ayyubi (Saladin) et quel fut son exploit majeur ?', 'difficile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le calife abbasside qui résista aux Croisés',false,0),(q,'Le sultan kurdo-arabe qui reconquit Jérusalem des Croisés en 1187',true,1),(q,'Le fondateur de l''empire ottoman',false,2),(q,'Le général mamelouk qui battit les Mongols',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Salah ad-Din Yusuf ibn Ayyub (1137-1193) unifia l''Égypte et la Syrie et reconquit Jérusalem le 2 octobre 1187 après 88 ans d''occupation croisée. Il était connu pour sa générosité même envers ses ennemis.',
   'إِن تَنصُرُوا اللَّهَ يَنصُرْكُمْ وَيُثَبِّتْ أَقْدَامَكُمْ',
   'Si vous aidez Allah, Il vous aidera et vous affermira.',
   'Sourate Muhammad (47:7)');

-- Q261 (difficile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Fiqh al-Aqalliyyat (jurisprudence des minorités) ?', 'difficile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Les règles islamiques uniquement pour les pays à majorité non-musulmane',false,0),(q,'La branche du fiqh traitant des situations juridiques spécifiques des musulmans vivant en pays non-islamiques',true,1),(q,'La jurisprudence pour les convertis récents',false,2),(q,'Les règles pour les migrants et réfugiés',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Fiqh al-Aqalliyyat étudie comment les musulmans minoritaires peuvent pratiquer leur religion tout en s''intégrant dans des sociétés non-islamiques. Il utilise des principes comme la Darura et la Maslaha.',
   'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
   'Allah n''impose à âme que ce qu''elle peut supporter.',
   'Sourate Al-Baqarah (2:286)');

-- Q262 (difficile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que l''Ijtihad et qui peut le pratiquer ?', 'difficile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Tout musulman qui connaît le Coran par cœur',false,0),(q,'L''effort de raisonnement juridique indépendant réservé aux savants qualifiés maîtrisant les sciences islamiques',true,1),(q,'L''opinion du Khalife ou du dirigeant',false,2),(q,'Le vote de la communauté sur une question religieuse',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''Ijtihad est l''effort intellectuel maximal d''un savant qualifié pour extraire un jugement juridique des sources. Conditions : maîtriser l''arabe, le Coran, la Sunna, l''Ijma'', le Qiyas et les Maqasid.',
   'وَلَوْ رَدُّوهُ إِلَى الرَّسُولِ وَإِلَىٰ أُولِي الْأَمْرِ مِنْهُمْ لَعَلِمَهُ الَّذِينَ يَسْتَنبِطُونَهُ مِنْهُمْ',
   'S''ils l''avaient référé au Messager et aux détenteurs de l''autorité parmi eux, ceux qui savent tirer les conclusions l''auraient su.',
   'Sourate An-Nisa (4:83)');

-- Q263 (difficile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Sadd al-Dhara''i'' en jurisprudence islamique ?', 'difficile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'L''ouverture des voies menant au bien',false,0),(q,'Le blocage des moyens et voies qui mènent probablement à ce qui est interdit',true,1),(q,'La méthode de raisonnement analogique',false,2),(q,'Le principe de précaution dans la jurisprudence',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Sadd al-Dhara''i'' consiste à interdire des actes licites en soi qui mènent probablement à des actes illicites. Ex : interdire la vente de raisins à un producteur de vin connu.',
   'وَلَا تَسُبُّوا الَّذِينَ يَدْعُونَ مِن دُونِ اللَّهِ فَيَسُبُّوا اللَّهَ عَدْوًا',
   'N''insultez pas ceux qu''ils invoquent en dehors d''Allah, de peur qu''ils n''insultent Allah par hostilité.',
   'Sourate Al-An''am (6:108)');

-- Q264 (difficile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Hiyalah (stratagème juridique) et est-elle permise ?', 'difficile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Toujours permise si elle atteint un objectif licite',false,0),(q,'Toujours interdite dans l''Islam',false,1),(q,'Débattue : les stratagèmes pour contourner les interdictions sont interdits, mais ceux pour obtenir le droit sont permis',true,2),(q,'Permise uniquement dans le commerce',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les Hiyalah sont des stratagèmes juridiques. Les Hanafites sont plus permissifs que les Hanbalites (Ibn Taymiyyah les condamne sévèrement). Le critère : sert-elle à contourner une interdiction ou à réaliser un droit légitime ?',
   'يُخَادِعُونَ اللَّهَ وَالَّذِينَ آمَنُوا وَمَا يَخْدَعُونَ إِلَّا أَنفُسَهُمْ',
   'Ils trompent Allah et les croyants, mais ils ne trompent qu''eux-mêmes.',
   'Sourate Al-Baqarah (2:9)');

-- Q265 (difficile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Takaful islamique et en quoi diffère-t-il de l''assurance conventionnelle ?', 'difficile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'C''est la même chose que l''assurance conventionnelle mais avec un nom arabe',false,0),(q,'Un système de garantie mutuelle islamique basé sur la contribution (Tabarru'') et le partage des risques, évitant le Riba et le Gharar',true,1),(q,'Une assurance-vie islamique réservée aux pèlerins',false,2),(q,'Un fonds de Zakat pour aider les démunis',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Takaful est basé sur la contribution volontaire (Tabarru'') et la mutualité. Il évite le Riba (intérêt), le Maysir (jeu) et le Gharar (incertitude excessive) présents dans les assurances conventionnelles.',
   'وَتَعَاوَنُوا عَلَى الْبِرِّ وَالتَّقْوَىٰ وَلَا تَعَاوَنُوا عَلَى الْإِثْمِ وَالْعُدْوَانِ',
   'Entraidez-vous dans la piété et la crainte d''Allah, ne vous entraidez pas dans le péché et l''agression.',
   'Sourate Al-Ma''idah (5:2)');

-- Q266 (difficile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Dhimmi dans le droit islamique classique et quels étaient ses droits ?', 'difficile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un esclave dans un État islamique sans droits',false,0),(q,'Un non-musulman sous protection islamique avec droits à la vie, propriété, culte et justice',true,1),(q,'Un converti récent à l''Islam avec statut spécial',false,2),(q,'Un citoyen étranger en visite dans un pays islamique',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Dhimmi est le non-musulman vivant sous protection (Dhimma) de l''État islamique. Il bénéficiait de la protection de sa vie, de ses biens, de son culte et de l''accès à la justice. En échange, il payait la Jizya.',
   'وَإِنْ أَحَدٌ مِّنَ الْمُشْرِكِينَ اسْتَجَارَكَ فَأَجِرْهُ حَتَّىٰ يَسْمَعَ كَلَامَ اللَّهِ',
   'Si l''un des associateurs te demande asile, accorde-le-lui jusqu''à ce qu''il entende la parole d''Allah.',
   'Sourate At-Tawbah (9:6)');

-- Q267 (difficile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que l''Istihsan (préférence juridique) et quelle école l''utilise principalement ?', 'difficile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'L''école Shafi''ite l''utilise principalement',false,0),(q,'L''école Hanafite — c''est abandonner le Qiyas général pour une analogie plus spécifique ou l''équité',true,1),(q,'L''école Hanbalite — c''est l''utilisation des hadiths faibles comme preuve',false,2),(q,'L''école Malikite — c''est la priorité donnée à la pratique des habitants de Médine',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''Istihsan (préférence) est une méthode Hanafite : préférer une solution plus équitable ou spécifique au lieu du Qiyas général quand cela sert mieux les intérêts de la Sharia. L''imam Shafi''i le critiquait.',
   'إِنَّ اللَّهَ يَأْمُرُ بِالْعَدْلِ وَالْإِحْسَانِ',
   'Allah ordonne la justice et l''excellence.',
   'Sourate An-Nahl (16:90)');

-- Q268 (difficile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la Maslaha Mursalah en jurisprudence islamique ?', 'difficile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La jurisprudence basée sur les opinions personnelles des savants',false,0),(q,'L''intérêt public non spécifiquement mentionné dans les textes, utilisé pour légiférer en accord avec les objectifs de la Sharia',true,1),(q,'Le consensus des Compagnons sur une question non mentionnée dans le Coran',false,2),(q,'L''application de la jurisprudence ancienne aux problèmes modernes',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Maslaha Mursalah (intérêt non attesté) est utilisée quand les textes ne traitent pas d''une question mais qu''on peut légiférer dans le sens des objectifs de la Sharia. Ex : la compilation du Coran en livre unique.',
   'وَمَا أَرْسَلْنَاكَ إِلَّا رَحْمَةً لِّلْعَالَمِينَ',
   'Nous ne t''avons envoyé qu''en miséricorde pour les mondes.',
   'Sourate Al-Anbiya (21:107)');

-- Q269 (difficile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quels sont les types de droits dans la jurisprudence islamique : Haqq Allah vs Haqq al-Ibad ?', 'difficile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Les prières obligatoires et les prières recommandées',false,0),(q,'Les droits d''Allah (actes d''adoration obligatoires) et les droits des hommes (droits civils, dettes, réparations)',true,1),(q,'Les droits des musulmans et les droits des non-musulmans',false,2),(q,'Les droits acquis à la naissance et ceux acquis par le mariage',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Haqq Allah (droit d''Allah) : prières, Zakat, jeûne... Allah peut pardonner si on se repent. Haqq al-Ibad (droit des hommes) : dettes, injustices... ne sont effacés que si la victime pardonne ou est indemnisée.',
   'إِنَّ اللَّهَ لَا يَظْلِمُ مِثْقَالَ ذَرَّةٍ',
   'Allah ne lèse personne d''un iota.',
   'Sourate An-Nisa (4:40)');

-- Q270 (difficile / jurisprudence)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la ''Urf (coutume) comme source auxiliaire du droit islamique ?', 'difficile', 'jurisprudence') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La coutume n''est jamais une source de droit islamique',false,0),(q,'La coutume locale peut être intégrée comme source auxiliaire si elle ne contredit pas le Coran ni la Sunna',true,1),(q,'La coutume est toujours prioritaire sur les hadiths',false,2),(q,'Seule la coutume des Compagnons est reconnue',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La ''Urf (coutume) est reconnue comme source auxiliaire si elle est : générale, stable, antérieure à l''acte et non contraire aux textes. Ex : les pratiques commerciales locales dans un contrat islamique.',
   'خُذِ الْعَفْوَ وَأْمُرْ بِالْعُرْفِ وَأَعْرِضْ عَنِ الْجَاهِلِينَ',
   'Pratique l''indulgence, ordonne le bien (''urf) et détourne-toi des ignorants.',
   'Sourate Al-A''raf (7:199)');

-- Lot 3c : difficile prophetes + foi + END $$ (Q271-Q340)

-- Q271 (difficile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est la position islamique sur la crucifixion d''Issa (Jésus) ?', 'difficile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Issa a été crucifié et ressuscité comme dans le christianisme',false,0),(q,'Issa est mort de vieillesse',false,1),(q,'Issa n''a pas été crucifié — il fut élevé vers Allah et un autre prit son apparence',true,2),(q,'Issa a été crucifié mais n''est pas mort',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Coran affirme clairement que les Juifs n''ont pas tué ni crucifié Issa — cela leur parut tel. Allah l''éleva vers Lui. Issa reviendra avant la Fin des Temps.',
   'وَمَا قَتَلُوهُ وَمَا صَلَبُوهُ وَلَٰكِن شُبِّهَ لَهُمْ',
   'Ils ne l''ont ni tué ni crucifié, mais cela leur parut tel.',
   'Sourate An-Nisa (4:157)');

-- Q272 (difficile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la "''Ismah" des prophètes et ses limites ?', 'difficile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Les prophètes sont infaillibles dans tous leurs actes y compris personnels',false,0),(q,'Les prophètes sont infaillibles dans la transmission du message mais peuvent faire des erreurs d''ijtihad non-intentionnelles',true,1),(q,'Les prophètes sont infaillibles uniquement concernant les piliers de l''Islam',false,2),(q,'La ''Ismah est un concept inventé par les Chiites',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La ''Ismah protège les prophètes de toute faute dans la transmission du message divin. Ils peuvent néanmoins faire des erreurs d''ijtihad (non-délibérées) dans des questions mondaines, puis être guidés vers la correction.',
   'عَفَا اللَّهُ عَنكَ لِمَ أَذِنتَ لَهُمْ',
   'Qu''Allah te pardonne ! Pourquoi leur as-tu accordé la permission ?',
   'Sourate At-Tawbah (9:43)');

-- Q273 (difficile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète est associé au peuple de ''Ad et quelle fut leur punition ?', 'difficile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Salih — punition : un tremblement de terre',false,0),(q,'Lut — punition : pluie de pierres',false,1),(q,'Hud — punition : un vent violent de 7 nuits et 8 jours',true,2),(q,'Nuh — punition : le déluge',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le prophète Hud fut envoyé vers le peuple de ''Ad en Arabie. Ils étaient grands et forts mais rejetèrent le message. Allah leur envoya un vent glacial de 7 nuits et 8 jours qui les anéantit.',
   'وَأَمَّا عَادٌ فَأُهْلِكُوا بِرِيحٍ صَرْصَرٍ عَاتِيَةٍ سَخَّرَهَا عَلَيْهِمْ سَبْعَ لَيَالٍ وَثَمَانِيَةَ أَيَّامٍ',
   'Quant à ''Ad, ils furent anéantis par un vent d''un froid violent et impétueux, qu''Allah déchaîna contre eux pendant sept nuits et huit jours.',
   'Sourate Al-Haqqah (69:6-7)');

-- Q274 (difficile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la particularité du prophète Idris (Énoch) mentionné dans le Coran ?', 'difficile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Il a vécu 950 ans et prêché son peuple',false,0),(q,'Il a été élevé à un lieu élevé (au Ciel) sans mourir selon certains savants',true,1),(q,'Il a reçu la Torah',false,2),(q,'Il a fondé la première mosquée',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Coran mentionne Idris comme véridique et prophète, et qu''Allah l''éleva à un lieu élevé. Les savants débattent s''il est encore vivant comme Issa ou s''il est décédé après son élévation.',
   'وَاذْكُرْ فِي الْكِتَابِ إِدْرِيسَ إِنَّهُ كَانَ صِدِّيقًا نَّبِيًّا وَرَفَعْنَاهُ مَكَانًا عَلِيًّا',
   'Mentionne dans le Livre Idris. Il était véridique et prophète. Nous l''avons élevé à un lieu élevé.',
   'Sourate Maryam (19:56-57)');

-- Q275 (difficile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète fut envoyé vers le peuple de Thamoud et quel fut le signe miraculeux qu''il leur donna ?', 'difficile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Hud — un déluge local',false,0),(q,'Shu''ayb — un tremblement de terre',false,1),(q,'Salih — une chamelle sortie miraculeusement du rocher',true,2),(q,'Ibrahim — un bélier du Paradis',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Salih fut envoyé vers Thamoud. Comme signe, Allah fit sortir miraculeusement une chamelle du rocher. Quand ils la tuèrent, Allah les frappa d''un cri foudroyant.',
   'وَيَا قَوْمِ هَٰذِهِ نَاقَةُ اللَّهِ لَكُمْ آيَةً فَذَرُوهَا تَأْكُلْ فِي أَرْضِ اللَّهِ',
   'Ô mon peuple ! Voici la chamelle d''Allah, signe pour vous. Laissez-la paître sur la terre d''Allah.',
   'Sourate Hud (11:64)');

-- Q276 (difficile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel était le talent particulier du prophète Daoud (David) au-delà de la prophétie ?', 'difficile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Il était l''architecte du Temple de Jérusalem',false,0),(q,'Il était roi, forgeron (cotte de mailles) et psalmiste doté d''une voix extraordinaire',true,1),(q,'Il pouvait transformer l''argile en oiseaux',false,2),(q,'Il commandait les djinns comme Sulayman',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Daoud reçut la capacité de mouler le fer pour fabriquer des cottes de mailles, une voix magnifique de louange, la sagesse du jugement, et le Zabur. Les montagnes et oiseaux chantaient avec lui.',
   'وَأَلَنَّا لَهُ الْحَدِيدَ أَنِ اعْمَلْ سَابِغَاتٍ وَقَدِّرْ فِي السَّرْدِ',
   'Nous ramollîmes pour lui le fer : ''Fabrique des cottes de mailles et calcule bien les mailles.''',
   'Sourate Saba (34:10-11)');

-- Q277 (difficile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le nom des dix compagnons assurés du Paradis (''Ashara Mubashshara) ?', 'difficile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Ce sont les noms des 10 premiers convertis à l''Islam',false,0),(q,'Abu Bakr, Umar, Uthman, Ali, Talha, Zubayr, Abd ar-Rahman ibn Awf, Abu ''Ubayda, Sa''d ibn Abi Waqqas, Sa''id ibn Zayd',true,1),(q,'Ce sont les 10 hafiz du Coran parmi les Compagnons',false,2),(q,'Ce sont les 10 premiers martyrs de l''Islam',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Prophète ﷺ mentionna 10 compagnons dans un seul hadith en les assurant du Paradis. Ces 10 sont les plus grands Compagnons et les plus méritants de la communauté.',
   'أَبُو بَكْرٍ فِي الْجَنَّةِ، وَعُمَرُ فِي الْجَنَّةِ، وَعُثْمَانُ فِي الْجَنَّةِ، وَعَلِيٌّ فِي الْجَنَّةِ',
   'Abu Bakr au Paradis, Umar au Paradis, Uthman au Paradis, Ali au Paradis...',
   'Jami'' at-Tirmidhi — Hadith n°3747');

-- Q278 (difficile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quelle est la différence entre un Nabi (prophète) et un Rasul (messager) dans la terminologie islamique ?', 'difficile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Ce sont des termes synonymes sans distinction',false,0),(q,'Tout Rasul est Nabi, mais pas tout Nabi n''est Rasul — le Rasul apporte une nouvelle loi ou est envoyé à un peuple particulier',true,1),(q,'Le Rasul est plus important car il peut faire des miracles',false,2),(q,'Le Nabi est envoyé aux humains, le Rasul aux djinns',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Selon les savants, le Rasul est un prophète envoyé avec un nouveau message et une communauté qui le rejette. Le Nabi continue la loi d''un Rasul précédent. Mais la définition exacte est débattue entre savants.',
   'وَمَا أَرْسَلْنَا مِن قَبْلِكَ مِن رَّسُولٍ وَلَا نَبِيٍّ إِلَّا إِذَا تَمَنَّىٰ أَلْقَى الشَّيْطَانُ فِي أُمْنِيَّتِهِ',
   'Nous n''avons envoyé avant toi ni messager ni prophète sans que le Diable ne tente de glisser [quelque chose] dans ses désirs.',
   'Sourate Al-Hajj (22:52)');

-- Q279 (difficile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel prophète fut envoyé vers Madyan et interdit les fraudes commerciales ?', 'difficile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Hud — vers ''Ad',false,0),(q,'Salih — vers Thamoud',false,1),(q,'Shu''ayb — vers Madyan',true,2),(q,'Lut — vers Sodome',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Shu''ayb fut envoyé vers les gens de Madyan (dans le nord-ouest de l''Arabie). Il leur interdit de tricher dans les mesures et balances. Ils le rejetèrent et furent punis par un cri et un tremblement.',
   'وَإِلَىٰ مَدْيَنَ أَخَاهُمْ شُعَيْبًا قَالَ يَا قَوْمِ اعْبُدُوا اللَّهَ وَأَوْفُوا الْمِكْيَالَ وَالْمِيزَانَ',
   'Et vers Madyan, leur frère Shu''ayb. Il dit : Ô mon peuple ! Adorez Allah et soyez justes dans les mesures et balances.',
   'Sourate Hud (11:84)');

-- Q280 (difficile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la "Khatam an-Nubuwwah" (Sceau de la prophétie) du Prophète ﷺ ?', 'difficile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un titre honorifique signifiant qu''il est le meilleur des prophètes',false,0),(q,'Le fait que Muhammad ﷺ est le dernier des prophètes — aucun prophète ne viendra après lui',true,1),(q,'Une marque physique sur le corps du Prophète ﷺ uniquement',false,2),(q,'Le Coran qui "scelle" et confirme tous les livres précédents',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Khatam an-Nubuwwah signifie que Muhammad ﷺ est le dernier prophète et messager. Aucun prophète ne viendra après lui. Tout nouveau prétendant à la prophétie est un imposteur (Dajjal).',
   'مَا كَانَ مُحَمَّدٌ أَبَا أَحَدٍ مِّن رِّجَالِكُمْ وَلَٰكِن رَّسُولَ اللَّهِ وَخَاتَمَ النَّبِيِّينَ',
   'Muhammad n''est le père d''aucun de vos hommes, mais le Messager d''Allah et le Sceau des prophètes.',
   'Sourate Al-Ahzab (33:40)');

-- Q281 (difficile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la croyance en "Ru''yat Allah" (voir Allah au Paradis) ?', 'difficile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'C''est une idée hérétique — Allah ne peut pas être vu',false,0),(q,'Les croyants verront Allah au Paradis — c''est la plus grande récompense selon les textes authentiques',true,1),(q,'Seuls les prophètes verront Allah',false,2),(q,'On ne peut pas se prononcer sur cette question',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La vision d''Allah au Paradis est le plus grand bonheur des croyants. Le Prophète ﷺ dit : "Vous verrez votre Seigneur comme vous voyez la pleine lune." C''est une croyance d''Ahl as-Sunnah.',
   'وُجُوهٌ يَوْمَئِذٍ نَّاضِرَةٌ إِلَىٰ رَبِّهَا نَاظِرَةٌ',
   'Des visages ce jour-là seront radieux, regardant vers leur Seigneur.',
   'Sourate Al-Qiyamah (75:22-23)');

-- Q282 (difficile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le "Tawhid ar-Rububiyyah" ?', 'difficile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Croire qu''Allah est unique dans Son adoration',false,0),(q,'Croire qu''Allah est l''unique Seigneur, Créateur, Pourvoyeur et Gouverneur de l''univers',true,1),(q,'Croire que les noms et attributs d''Allah sont parfaits',false,2),(q,'Le Tawhid dans les jugements et législation',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Tawhid ar-Rububiyyah est la première dimension du Tawhid : reconnaître qu''Allah seul crée, pourvoit, donne la vie, donne la mort et gouverne l''univers. Même les polythéistes reconnaissaient cela.',
   'وَلَئِن سَأَلْتَهُم مَّنْ خَلَقَ السَّمَاوَاتِ وَالْأَرْضَ لَيَقُولُنَّ اللَّهُ',
   'Si tu leur demandes qui a créé les cieux et la terre, ils diront certainement : Allah.',
   'Sourate Az-Zumar (39:38)');

-- Q283 (difficile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le "Tawhid al-Uluhiyyah" et en quoi est-il essentiel ?', 'difficile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Croire qu''Allah est l''unique Créateur',false,0),(q,'Croire qu''Allah est unique dans les noms et attributs',false,1),(q,'Sincérer toute adoration uniquement pour Allah — c''est le but de l''envoi des prophètes',true,2),(q,'Croire que la révélation divine est authentique',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Tawhid al-Uluhiyyah (Tawhid de l''adoration) est la finalité de tous les prophètes : que toute adoration — prière, jeûne, sacrifice, vœu, crainte, espoir — soit dirigée vers Allah seul.',
   'وَمَا أُمِرُوا إِلَّا لِيَعْبُدُوا اللَّهَ مُخْلِصِينَ لَهُ الدِّينَ',
   'Il ne leur a été commandé que d''adorer Allah en Lui vouant un culte pur.',
   'Sourate Al-Bayyinah (98:5)');

-- Q284 (difficile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le "Tawhid al-Asma'' was-Sifat" (Tawhid des noms et attributs) ?', 'difficile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Connaître par cœur les 99 noms d''Allah',false,0),(q,'Affirmer pour Allah tous les noms et attributs qu''Il S''est attribués, sans les nier ni les comparer aux attributs humains',true,1),(q,'Croire qu''Allah n''a aucun attribut car Il est incomparable',false,2),(q,'Interpréter allégoriquement tous les attributs d''Allah',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La méthode d''Ahl as-Sunnah dans les attributs divins : les affirmer tels qu''ils sont dans les textes sans tashbih (comparaison), ta''til (négation), tahrif (déformation) ni takyif (description de la modalité).',
   'لَيْسَ كَمِثْلِهِ شَيْءٌ وَهُوَ السَّمِيعُ الْبَصِيرُ',
   'Rien ne Lui est semblable, et Il est l''Audient, le Voyant.',
   'Sourate Ash-Shura (42:11)');

-- Q285 (difficile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le mouvement Mu''tazilite et sa position sur la nature du Coran ?', 'difficile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le Mu''tazilisme affirmait que le Coran est éternel et incréé',false,0),(q,'Le Mu''tazilisme affirmait que le Coran est créé (makhluk) — position condamnée par les savants d''Ahl as-Sunnah',true,1),(q,'Le Mu''tazilisme niait la valeur du Coran',false,2),(q,'Le Mu''tazilisme est une école de jurisprudence islamique',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les Mu''tazilites (8-10ème siècles) soutenaient que le Coran est créé. L''imam Ahmad ibn Hanbal fut persécuté pour avoir défendu la position orthodoxe : le Coran est la parole d''Allah et n''est pas créé.',
   'قُلْ لَّوْ كَانَ الْبَحْرُ مِدَادًا لِّكَلِمَاتِ رَبِّي لَنَفِدَ الْبَحْرُ قَبْلَ أَن تَنفَدَ كَلِمَاتُ رَبِّي',
   'Dis : Si la mer était de l''encre pour les paroles de mon Seigneur, la mer s''épuiserait avant que s''épuisent Ses paroles.',
   'Sourate Al-Kahf (18:109)');

-- Q286 (difficile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Nifaq (hypocrisie) et quels sont ses signes selon les hadiths ?', 'difficile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'L''hypocrisie est simplement le fait de faire semblant d''être pieux',false,0),(q,'Il y a le Nifaq d''action (mentir, trahir, rompre les engagements) et le Nifaq de croyance (cacher la mécréance)',true,1),(q,'L''hypocrisie concerne uniquement les questions de prière',false,2),(q,'Le Nifaq est un péché mineur facilement pardonnable',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Prophète ﷺ dit : "Quatre signes font l''hypocrite parfait : mentir, trahir, rompre les promesses, agir de façon obscène dans les disputes." Le Nifaq de croyance est la plus grave des formes.',
   'آيَةُ الْمُنَافِقِ ثَلَاثٌ: إِذَا حَدَّثَ كَذَبَ وَإِذَا وَعَدَ أَخْلَفَ وَإِذَا اؤْتُمِنَ خَانَ',
   'Trois signes de l''hypocrite : quand il parle il ment, quand il promet il manque à sa parole, quand on lui confie quelque chose il trahit.',
   'Sahih Bukhari — Hadith n°33');

-- Q287 (difficile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la différence entre la Mahabbah (amour) et le Khawf (crainte) d''Allah en Islam ?', 'difficile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'On doit uniquement aimer Allah sans Le craindre',false,0),(q,'On doit uniquement craindre Allah sans L''aimer',false,1),(q,'L''adoration parfaite combine amour, crainte et espoir — les trois sont nécessaires',true,2),(q,'La crainte d''Allah est supérieure à Son amour',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les savants comme Ibn al-Qayyim expliquent que l''adoration parfaite est comme un oiseau : le corps est l''amour, les deux ailes sont la crainte (Khawf) et l''espoir (Raja''). Sans les trois, l''adoration est incomplète.',
   'يُحِبُّهُمْ وَيُحِبُّونَهُ أَذِلَّةٍ عَلَى الْمُؤْمِنِينَ أَعِزَّةٍ عَلَى الْكَافِرِينَ',
   'Il les aime et ils L''aiment, humbles envers les croyants, fiers face aux mécréants.',
   'Sourate Al-Ma''idah (5:54)');

-- Q288 (difficile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Zuhd (ascétisme) islamique et en quoi diffère-t-il du monachisme ?', 'difficile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le Zuhd islamique est identique au monachisme chrétien',false,0),(q,'Le Zuhd islamique consiste à ne pas attacher son cœur aux biens mondains tout en les utilisant ; il ne rejette pas le mariage ni le travail',true,1),(q,'Le Zuhd interdit tout plaisir mondain',false,2),(q,'Le Zuhd est une innovation condamnée en Islam',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'L''Islam interdit le monachisme. Le vrai Zuhd islamique : se désintéresser du mondain dans le cœur tout en l''utilisant normalement. Le Prophète ﷺ était marié, mangeait, commerçait — et était le plus zuhi.',
   'وَلَا تَنسَ نَصِيبَكَ مِنَ الدُّنْيَا وَأَحْسِن كَمَا أَحْسَنَ اللَّهُ إِلَيْكَ',
   'N''oublie pas ta part de ce monde, et fais du bien comme Allah a fait du bien envers toi.',
   'Sourate Al-Qasas (28:77)');

-- Q289 (difficile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la doctrine des "Ashari" concernant la foi (Iman) ?', 'difficile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La foi est uniquement la croyance dans le cœur sans actes',false,0),(q,'La foi est la croyance dans le cœur et la déclaration de la langue — les actes en sont une conséquence',true,1),(q,'La foi est uniquement les actes extérieurs',false,2),(q,'La foi se résume à la prononciation de la Shahada',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Selon l''école Ash''arite (largement répandue), l''Iman est dans le cœur (Tasdiq) et la langue (Iqrar). Pour les salafis et les Hanbalites, les actes font partie de la foi et peuvent augmenter ou diminuer.',
   'إِنَّمَا الْمُؤْمِنُونَ الَّذِينَ إِذَا ذُكِرَ اللَّهُ وَجِلَتْ قُلُوبُهُمْ',
   'Les vrais croyants sont ceux dont les cœurs frémissent quand Allah est mentionné.',
   'Sourate Al-Anfal (8:2)');

-- Q290 (difficile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Wali Allah (ami d''Allah) selon le Coran et la Sunna ?', 'difficile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un personnage saint élu par Allah indépendamment de ses actes',false,0),(q,'Un homme que les gens déclarent saint après sa mort',false,1),(q,'Tout croyant pieux qui croit sincèrement et craint Allah — la wilaya est accessible à tous',true,2),(q,'Uniquement les compagnons du Prophète ﷺ',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Coran définit clairement le Wali Allah : c''est le croyant qui craint Allah et l''adore avec sincérité. Tout croyant pieux peut atteindre ce statut. Les miracles des Awliya sont réels mais subordonnés à la Sunna.',
   'أَلَا إِنَّ أَوْلِيَاءَ اللَّهِ لَا خَوْفٌ عَلَيْهِمْ وَلَا هُمْ يَحْزَنُونَ الَّذِينَ آمَنُوا وَكَانُوا يَتَّقُونَ',
   'Les amis d''Allah — nulle crainte sur eux, ils ne seront pas affligés — ceux qui ont cru et se sont prémunis.',
   'Sourate Yunus (10:62-63)');

-- Q291 (difficile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la doctrine islamique sur Yajuj et Majuj (Gog et Magog) ?', 'difficile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Ce sont des peuples fictifs mentionnés symboliquement dans le Coran',false,0),(q,'Ce sont deux tribus nombreuses actuellement retenues derrière une barrière construite par Dhul-Qarnayn et qui surgiront à la Fin des Temps',true,1),(q,'Ce sont les descendants de Caïn et Abel',false,2),(q,'C''est le nom islamique des Mongols qui ont envahi le monde islamique',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Yajuj et Majuj sont deux peuples retardés par la barrière de Dhul-Qarnayn. Leur déferlement est l''un des grands signes de la Fin des Temps. La barrière s''affaiblit et sera brisée après la mort de Issa.',
   'حَتَّىٰ إِذَا فُتِحَتْ يَأْجُوجُ وَمَأْجُوجُ وَهُم مِّن كُلِّ حَدَبٍ يَنسِلُونَ',
   'Jusqu''à ce que Yajuj et Majuj soient ouverts et qu''ils se précipitent de chaque hauteur.',
   'Sourate Al-Anbiya (21:96)');

-- Q292 (difficile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le Mahdi attendu selon les hadiths et son rôle dans les Fins des Temps ?', 'difficile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le Mahdi est une invention des Chiites — les sunnites ne le croient pas',false,0),(q,'Un homme de la descendance du Prophète ﷺ qui rétablira la justice et l''unité de l''Umma avant la Fin des Temps',true,1),(q,'Le Mahdi est un titre que les croyants doivent rechercher parmi les savants',false,2),(q,'Le Mahdi est Issa (Jésus) lui-même sous un autre nom',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Mahdi est mentionné dans des hadiths authentiques chez Abu Daoud, Tirmidhi et Ibn Majah. Il sera de la descendance du Prophète ﷺ, s''appellera Muhammad ibn Abdullah et remplira la terre de justice.',
   'لَوْ لَمْ يَبْقَ مِنَ الدُّنْيَا إِلَّا يَوْمٌ لَطَوَّلَ اللَّهُ ذَلِكَ الْيَوْمَ حَتَّى يَبْعَثَ فِيهِ رَجُلًا مِنِّي',
   'Si de la Dunya il ne restait qu''un jour, Allah le prolongerait jusqu''à y envoyer un homme de moi.',
   'Sunan Abu Daoud — Hadith n°4282');

-- Q293 (difficile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quel est le rôle du Dajjal dans les événements de la Fin des Temps selon l''Islam ?', 'difficile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Le Dajjal est uniquement un symbole de l''hypocrisie',false,0),(q,'Un imposteur qui prétendra être le Messie et finalement être Dieu — il sera tué par Issa à sa redescente',true,1),(q,'Satan lui-même qui apparaîtra sous forme humaine',false,2),(q,'Un dirigeant politique injuste de la Fin des Temps',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Dajjal (Anti-Christ islamique) sera borgne, prétendra être Dieu, fera des miracles et séduira des millions. Il sera tué par Issa à Ludd (Lod, en Palestine). Le Prophète ﷺ le mentionna dans de nombreux hadiths.',
   'إِنَّهُ أَعْوَرُ وَإِنَّ رَبَّكُمْ لَيْسَ بِأَعْوَرَ',
   'Il est borgne, et votre Seigneur n''est pas borgne.',
   'Sahih Bukhari — Hadith n°7131');

-- Q294 (difficile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le principe islamique du "La Darar wa La Dirar" ?', 'difficile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'L''interdiction de tuer en Islam',false,0),(q,'Le principe juridique : ni nuire ni nuire en retour — l''Islam interdit de causer du tort à autrui',true,1),(q,'L''interdiction du mensonge et de la tromperie',false,2),(q,'Le principe de réciprocité dans les contrats',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'"La Darar wa La Dirar" (ni tort ni contre-tort) est l''un des 5 grands principes du fiqh islamique. Il signifie qu''on ne doit ni causer de préjudice ni riposter avec un préjudice similaire.',
   'لَا ضَرَرَ وَلَا ضِرَارَ',
   'Ni tort ni contre-tort.',
   'Hadith authentique — Ibn Majah et Musnad Ahmad');

-- Q295 (difficile / foi)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le "Tazkiyat an-Nafs" (purification de l''âme) comme chemin spirituel en Islam ?', 'difficile', 'foi') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'L''accomplissement des 5 piliers uniquement',false,0),(q,'La purification de l''âme de ses maladies (orgueil, envie, avarice) et son ornement de vertus islamiques',true,1),(q,'La mémorisation du Coran',false,2),(q,'Les séances de Dhikr dans les mosquées',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Tazkiyah est l''une des missions du Prophète ﷺ. Elle vise à purifier l''âme des maladies du cœur (Riya, Kibr, Hasad) et à la parer de vertus (Ikhlas, Tawadu'', Shukr). C''est le sens du Tasawwuf authentique.',
   'قَدْ أَفْلَحَ مَن زَكَّاهَا وَقَدْ خَابَ مَن دَسَّاهَا',
   'A réussi celui qui la purifie ! A échoué celui qui la souille !',
   'Sourate Ash-Shams (91:9-10)');

-- Q296 (difficile / piliers)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la prière de l''éclipse (Salat al-Kusuf) et dans quelles circonstances est-elle accomplie ?', 'difficile', 'piliers') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Prière accomplie le 1er de chaque mois lunaire',false,0),(q,'Prière accomplie lors des éclipses de soleil ou de lune pour glorifier Allah et s''humilier devant Lui',true,1),(q,'Prière spéciale pour demander la pluie',false,2),(q,'Prière accomplie lors des tremblements de terre',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Salat al-Kusuf (éclipse) est une Sunna Muakkadah. Le Prophète ﷺ dit : "Le soleil et la lune ne s''éclipsent pas à cause de la mort ou de la naissance de quelqu''un — ils sont des signes d''Allah."',
   'إِنَّ الشَّمْسَ وَالْقَمَرَ آيَتَانِ مِنْ آيَاتِ اللَّهِ',
   'Le soleil et la lune sont deux signes parmi les signes d''Allah.',
   'Sahih Bukhari — Hadith n°1040');

-- Q297 (difficile / coran)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que les "Fawatih as-Suwar" dans la science du Coran ?', 'difficile', 'coran') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Les premières révélations du Coran',false,0),(q,'Les ouvertures des sourates — 10 types différents dont les lettres isolées, la Basmala, les louanges, etc.',true,1),(q,'Les versets de la sourate Al-Fatiha',false,2),(q,'Les sourates qui commencent par une question',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les Fawatih as-Suwar (ouvertures des sourates) ont 10 types : Thana (louange), Tasbih, Huruf Muqatta''at, Nida (appel), Khabar (nouvelle), Qasam (serment), Shart (condition), Amr (ordre), Su''al (question), Ta''lil (cause).',
   'وَلَقَدْ يَسَّرْنَا الْقُرْآنَ لِلذِّكْرِ فَهَلْ مِن مُّدَّكِرٍ',
   'Nous avons facilité le Coran pour qu''on le rappelle. Y a-t-il quelqu''un pour s''en souvenir ?',
   'Sourate Al-Qamar (54:17)');

-- Q298 (difficile / hadith)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que le "Gharib al-Hadith" dans les sciences du hadith ?', 'difficile', 'hadith') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Un hadith étrange et rejeté',false,0),(q,'Un hadith transmis par un seul narrateur à un niveau de la chaîne (Fard) ou contenant des mots rares',true,1),(q,'Un hadith d''une culture étrangère à l''Islam',false,2),(q,'Un hadith dont on ignore l''origine',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Le Gharib désigne soit un hadith transmis par un seul narrateur (Fard), soit un texte contenant des expressions peu connues. Ibn al-Athir compila un dictionnaire célèbre : "An-Nihaya fi Gharib al-Hadith".',
   'بَلِّغُوا عَنِّي وَلَوْ آيَةً',
   'Transmettez de ma part, même si c''est un verset.',
   'Sahih Bukhari — Hadith n°3461');

-- Q299 (difficile / histoire)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Qu''est-ce que la "Bayt al-Hikmah" (Maison de la Sagesse) de Baghdad ?', 'difficile', 'histoire') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'La bibliothèque personnelle du Calife',false,0),(q,'Le grand centre de traduction, de recherche et de sciences fondé sous les Abbassides au 9ème siècle — sommet de l''âge d''or islamique',true,1),(q,'L''école de jurisprudence de l''imam Shafi''i à Baghdad',false,2),(q,'Le palais royal des califes abbassides',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'La Bayt al-Hikmah fut fondée sous Harun ar-Rashid et développée par Al-Ma''mun (813-833). Elle traduisit les savoirs grecs, perses et indiens, et produisit des avancées en mathématiques, astronomie, médecine et philosophie.',
   'قُلْ هَلْ يَسْتَوِي الَّذِينَ يَعْلَمُونَ وَالَّذِينَ لَا يَعْلَمُونَ',
   'Dis : Sont-ils égaux, ceux qui savent et ceux qui ne savent pas ?',
   'Sourate Az-Zumar (39:9)');

-- Q300 (difficile / prophetes)
INSERT INTO questions (texte, niveau, categorie) VALUES
  ('Quels sont les cinq devoirs du musulman envers le Prophète Muhammad ﷺ ?', 'difficile', 'prophetes') RETURNING id INTO q;
INSERT INTO options (question_id, texte, est_correct, ordre) VALUES
  (q,'Uniquement l''aimer et obéir à ses hadiths',false,0),(q,'Le croire, l''aimer plus que tout, l''obéir, l''imiter et le défendre par la parole et l''action',true,1),(q,'Uniquement réciter la Salat sur lui (Salam)',false,2),(q,'Uniquement suivre ses hadiths dans les actes d''adoration',false,3);
INSERT INTO dalils (question_id, explication, texte_arabe, traduction, reference) VALUES
  (q,'Les droits du Prophète ﷺ : le croire comme dernier messager, l''aimer plus que soi-même, lui obéir en toute chose, suivre sa Sunna et le défendre contre les calomnies. Ces droits font partie de l''Islam.',
   'النَّبِيُّ أَوْلَىٰ بِالْمُؤْمِنِينَ مِنْ أَنفُسِهِمْ',
   'Le Prophète est plus proche des croyants qu''ils ne le sont d''eux-mêmes.',
   'Sourate Al-Ahzab (33:6)');

END $$;
