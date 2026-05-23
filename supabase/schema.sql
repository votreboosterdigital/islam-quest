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
