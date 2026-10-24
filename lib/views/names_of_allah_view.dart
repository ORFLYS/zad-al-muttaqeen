// views/names_of_allah_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class NamesOfAllahView extends StatefulWidget {
  const NamesOfAllahView({super.key});

  @override
  State<NamesOfAllahView> createState() => _NamesOfAllahViewState();
}

class _NamesOfAllahViewState extends State<NamesOfAllahView> {
  final List<Map<String, String>> names = [
    {"name": "الرَّحْمَنُ", "meaning": "واسع الرحمة الذي وسعت رحمته كل شيء في الوجود.", "benefit": "تلاوته تبعث الطمأنينة والهدوء في النفس والرزق."},
    {"name": "الرَّحِيمُ", "meaning": "المنعم برحمته على عباده المؤمنين خاصة في الآخرة.", "benefit": "قراءته تورث رقة القلب والقبول والود بين الناس."},
    {"name": "الْمَلِكُ", "meaning": "صاحب السلطان والملك التام الذي يدبر شؤون خلقه.", "benefit": "يورث الاستغناء عن الخلق ونيل العزة والهيبة."},
    {"name": "الْقُدُّوسُ", "meaning": "المنزه والمطهر عن كل عيب ونقص وشبيه.", "benefit": "ينقي القلب من الغل والحسد والشهوات النفسية."},
    {"name": "السَّلَامُ", "meaning": "ناشر السلام والأمن بين خلقه، المبرأ من الآفات.", "benefit": "ينفع لشفاء المرضى ونزول السكينة في البيوت."},
    {"name": "الْمُؤْمِنُ", "meaning": "المصدق لعباده، واهب الأمن والأمان للخائفين.", "benefit": "يحفظ القارئ من وساوس الشيطان ومخاوف الدهر."},
    {"name": "الْمُهَيْمِنُ", "meaning": "الرقيب الحافظ الشاهد على خلقه والمهيمن عليهم.", "benefit": "يورث صفاء النفس والاطلاع على حقائق الأمور."},
    {"name": "الْعَزِيزُ", "meaning": "الغالب القوي الذي لا يغلب، منيع الجانب سبحانه.", "benefit": "يُكسب القارئ وقاراً وعزة ولا يذل لغير الله."},
    {"name": "الْجَبَّارُ", "meaning": "الذي يجبر كسر القلوب، وينفذ أمره في كل شيء.", "benefit": "يحفظ من ظلم الجبارين والأعداء ويكسر حدة الخوف."},
    {"name": "الْمُتَكَبِّرُ", "meaning": "المنفرد بصفات العظمة والكبرياء المتعالي عن النقص.", "benefit": "يورث الهيبة والرفعة والظفر في الأمور الصعبة."},
    {"name": "الْخَالِقُ", "meaning": "الموجد للأشياء من العدم على غير مثال سابق.", "benefit": "ينور القلب ويسهل معالجة الأمور المعقدة."},
    {"name": "الْبَارِئُ", "meaning": "الذي خلق الخلق بريئاً من التفاوت والاختلاف.", "benefit": "ينجي من الأمراض والعلل والأسقام النفسية والجسدية."},
    {"name": "الْمُصَوِّرُ", "meaning": "الذي يعطي كل مخلوق صورته وشكله المتميز البديع.", "benefit": "مفيد لطلب الذرية الصالحة والنجاح الفني والإبداعي."},
    {"name": "الْغَفَّارُ", "meaning": "كثير المغفرة لذنوب عباده والساتر لعيوبهم.", "benefit": "يغفر الذنوب ويسدل ستر الله الجميل على قارئه."},
    {"name": "الْقَهَّارُ", "meaning": "الذي يقهر الجبابرة ويذل العتاة ويسيطر على كل شيء.", "benefit": "يقطع دابر الأعداء ويطرد الوساوس والهم والغم."},
    {"name": "الْوَهَّابُ", "meaning": "كثير الهبات والعطايا دون مقابل وبلا حدود.", "benefit": "يجلب الرزق الواسع ويسهل تحصيل المطالب."},
    {"name": "الرَّزَّاقُ", "meaning": "الذي يتكفل برزق خلقه جميعاً ويوصله إليهم.", "benefit": "مفتاح مجرب لزيادة الأرزاق والبركة في المال والولد."},
    {"name": "الْفَتَّاحُ", "meaning": "الذي يفتح أبواب الرحمة والأرزاق والعلوم لعباده.", "benefit": "يفتح القلوب المقفلة ويسهل الأمور المغلقة."},
    {"name": "الْعَلِيمُ", "meaning": "المحيط بكل شيء علماً، ظاهره وباطنه، سره وعلنه.", "benefit": "يزيد الفهم والذكاء وينور البصيرة ويسهل طلب العلم."},
    {"name": "الْقَابِضُ", "meaning": "الذي يضيق الرزق ويبسطه بحكمته، ويقبض الأرواح.", "benefit": "يحفظ من كيد السوء ويهذب النفس الجامحة."},
    {"name": "الْبَاسِطُ", "meaning": "الذي يوسع الرزق لخواص عباده ويملأ القلوب فرحاً.", "benefit": "يشرح الصدر ويزيل الخوف والضيق والاكتئاب."},
    {"name": "الْخَافِضُ", "meaning": "الذي يخفض الكفار والأشقياء ويذل أهل التكبر.", "benefit": "يحمي من شرور المتكبرين ويرفع المظلومين."},
    {"name": "الرَّافِعُ", "meaning": "الذي يرفع شأن المؤمنين ويسعد الأتقياء في الدارين.", "benefit": "يرفع الدرجات والمقامات الدنيوية والأخروية."},
    {"name": "الْمُعِزُّ", "meaning": "المعطي للعزة لمن يشاء من عباده المخلصين.", "benefit": "يمنح الهيبة والشرف والمكانة المرموقة بين العباد."},
    {"name": "الْمُذِلُّ", "meaning": "الذي يوقع الذل بالظالمين وينزع عنهم المهابة.", "benefit": "ينجي من كيد الحساد ويسلب هيبة العدو في المواجهة."},
    {"name": "السَّمِيعُ", "meaning": "الذي يسمع كل الأصوات والنداءات ولا يشغله سمع عن سمع.", "benefit": "يضمن استجابة الدعوات ويقوي السمع والتركيز للذاكر."},
    {"name": "الْبَصِيرُ", "meaning": "المحيط بكل المبصرات يرى دبيب النملة السوداء في الليلة الظلماء.", "benefit": "ينور العين والبصيرة ويكسب الفطنة واليقين والتقوى."},
    {"name": "الْحَكَمُ", "meaning": "صاحب الحكم العادل والشرع المبين والعدل القاطع.", "benefit": "يورث الحكمة والعدل والإلهام الصادق في تدبير الأمور."},
    {"name": "الْعَدْلُ", "meaning": "المنصف في أحكامه، المنزه عن الظلم والجور.", "benefit": "يصلح النفوس المعوجة ويزرع العدل والإنصاف بقلب صاحبه."},
    {"name": "اللَّطِيفُ", "meaning": "البر بعباده المحسن إليهم برفق وخفاء ولطف.", "benefit": "مجرب لتفريج الهموم الشديدة ودفع البلايا والشدائد الكبرى."},
    {"name": "الْخَبِيرُ", "meaning": "العالم بدقائق الأشياء وبواطن الأمور وخبايا النفوس.", "benefit": "يكشف خفايا الأمور ويزيل المخاوف والهموم والاضطراب."},
    {"name": "الْحَلِيمُ", "meaning": "الذي لا يعجل بالعقوبة على العصاة بل يمهلهم توبة.", "benefit": "يسكن الغضب والتوتر ويورث الحلم والهدوء والسكينة النفسية."},
    {"name": "الْعَظِيمُ", "meaning": "صاحب العظمة والجلال التام الذي يستحق التعظيم.", "benefit": "يكسب الجلال والوقار والمهابة والترقي في العمل."},
    {"name": "الْغَفُورُ", "meaning": "كثير الغفران والصفح للمستغفرين التائبين.", "benefit": "يذهب الهم والغم ويجلب راحة البال ومغفرة الخطايا الكبيرة."},
    {"name": "الشَّكُورُ", "meaning": "الذي يضاعف الثواب على العمل الصغير ويجزي بالخير والنعيم.", "benefit": "يشفي الأمراض الجسدية والنفسية ويزيد نعم الله."},
    {"name": "الْعَلِيُّ", "meaning": "الرفيع الشأن والمقام المتعالي عن الأشباه والأنداد.", "benefit": "يساعد على علو المنزلة والظفر بالنجاح والقبول."},
    {"name": "الْكَبِيرُ", "meaning": "الذي له الكبرياء والعظمة والعلو المطلق.", "benefit": "يفتح أبواب الشرف والرفعة والنجاح الباهر لفاعله."},
    {"name": "الْحَفِيظُ", "meaning": "الحافظ لكل مخلوقاته، الحامي لعباده من المهالك.", "benefit": "درع واقٍ لحفظ الأبناء، المنازل، الأموال، والأنفس من السوء."},
    {"name": "الْمُقِيتُ", "meaning": "الموصل الأقوات لأبدان خلقه وأرواحهم وحافظها.", "benefit": "يذهب الجوع ويسهل قضاء الحوائج المعيشية ونيل الرزق."},
    {"name": "الْحَسِيبُ", "meaning": "الكافي لعباده، الشاهد عليهم والمحاسب لهم برفق.", "benefit": "يكفي شر الأعداء والحساد ويقي من وساوس السوء وضيق العيش."},
    {"name": "الْجَلِيلُ", "meaning": "الموصوف بصفات الجلال والكمال البديع المطلق.", "benefit": "يعطي صاحبه الكرامة والشرف والعزة ويوقره كل من يراه."},
    {"name": "الْكَرِيمُ", "meaning": "الذي يعطي بلا حساب ويبتدي بالنعم قبل الاستحقاق.", "benefit": "يجلب الكرامة والبركة والنجاح الدائم ويبعد الفقر والمهانة."},
    {"name": "الرَّقِيبُ", "meaning": "الرقيب الذي لا يغيب عنه شيء الحافظ لكل شاردة وواردة.", "benefit": "يحفظ العائلة والممتلكات عند السفر ويبعد الغفلة."},
    {"name": "الْمُجِيبُ", "meaning": "الذي يقبل دعاء الداعين ويثيب السائلين برحمته.", "benefit": "يسرع استجابة الدعاء وخاصة في أوقات الشدة والضيق المالي."},
    {"name": "الْوَاسِعُ", "meaning": "واسع الصفات والرحمة والمغفرة والأرزاق لعباده.", "benefit": "يوسع الأرزاق والأخلاق ويذهب الضيق والتوتر الصدري."},
    {"name": "الْحَكِيمُ", "meaning": "الذي يضع الأشياء في مواضعها الصحيحة المتقن لصنعه.", "benefit": "يورث الحكمة وسداد الرأي والنجاح العلمي والعملي الباهر."},
    {"name": "الْوَدُودُ", "meaning": "الذي يحب عباده الصالحين ويتودد إليهم بنعمه الفياضة.", "benefit": "ينشر المحبة والألفة في البيوت وبين الزوجين ويزيل البغضاء."},
    {"name": "الْمَجِيدُ", "meaning": "شريف الذات والصفات، المحمود بكل معاني العظمة والجمال.", "benefit": "يشفي من الأمراض المستعصية ويعلي من شأن القارئ بالكرامة."},
    {"name": "الْبَاعِثُ", "meaning": "الذي يبعث الموتى من القبور للحساب، وباعث الهمم.", "benefit": "يحيي القلوب الميتة باليقين والإيمان وينشط الكسول."},
    {"name": "الشَّهِيدُ", "meaning": "الحاضر المطلع على كل غيب وشهادة، الشاهد على خلقه.", "benefit": "يصلح الأولاد والزوجين المشاكسين ويهدي الضالين."},
    {"name": "الْحَقُّ", "meaning": "الموجود حقاً، الثابت الذي لا يزول ولا يتغير سبحانه.", "benefit": "يظهر الحقيقة الضائعة ويرد كيد الباطل والظالمين."},
    {"name": "الْوَكِيلُ", "meaning": "الكفيل بأرزاق العباد ومصالحهم، المعتمد عليه في كل شيء.", "benefit": "ينجي من الحروق والغرق والمخاوف الكبرى ويفتح سبل النجاة."},
    {"name": "الْقَوِيُّ", "meaning": "صاحب القدرة الكاملة والقوة التامة التي لا تعجز.", "benefit": "يقوي البدن الضعيف ويذهب الخوف والوهن والتردد النفسي."},
    {"name": "الْمَتِينُ", "meaning": "شديد القوة والمنعة والقدرة الذي لا يغلبه شيء.", "benefit": "يصلح البدن ويعين على تحمل مشاق العبادة والأعمال الصعبة."},
    {"name": "الْوَلِيُّ", "meaning": "المحب لعباده المؤمنين الناصر لهم والمعين في شدتهم.", "benefit": "يجعل صاحبه محبوباً ومستجاب الدعوة ويقربه من الصالحين."},
    {"name": "الْحَمِيدُ", "meaning": "المستحق للحمد والثناء لجميل ذاته وعظيم صفاته.", "benefit": "يحسن السيرة والسمعة بين العباد ويذهب العادات السيئة."},
    {"name": "الْمُحْصِي", "meaning": "الذي أحصى كل شيء علماً وعدداً لا يفوته شيء.", "benefit": "يساعد على التركيز والحفظ وقدرات التعلم العقلي السريع."},
    {"name": "المُبْدِئُ", "meaning": "الموجد للأشياء من العدم على غير مثال سابق.", "benefit": "يبعث التوفيق والبركة في المشروعات والأعمال الجديدة."},
    {"name": "الْمُعِيدُ", "meaning": "الذي يعيد الخلق بعد فنائهم ويبعثهم من القبور.", "benefit": "يساعد على استعادة المفقودات والأشياء والفرص الضائعة."},
    {"name": "الْمُحْيِي", "meaning": "الذي يحيي العظام وهي رميم، المانح للحياة للأنفس.", "benefit": "يحيي النفوس الكسولة بالنشاط ويقوي الصحة الجسدية."},
    {"name": "المُمِيتُ", "meaning": "الذي يثبت الموت لكل حي ويسلب الروح بحكمته.", "benefit": "يساعد على كبح جماح الشهوات النفسية السيئة والانتصار عليها."},
    {"name": "الْحَيُّ", "meaning": "الباقي دائماً بلا زوال، المتصف بالحياة الكاملة الدائمة.", "benefit": "يورث طول العمر والشفاء والنشاط والبركة المعيشية الكبيرة."},
    {"name": "الْقَيُّومُ", "meaning": "القائم بنفسه، المقيم لغيره، المدبر لشؤون خلقه.", "benefit": "تكراره مع الحي (يا حي يا قيوم) يكشف الكروب العظام ويسر الأمور."},
    {"name": "الْوَاجِدُ", "meaning": "الذي يجد كل ما يريده ولا يعوزه شيء، غني الذات.", "benefit": "يورث قناعة النفس والاستغناء والعثور على الحوائج."},
    {"name": "الْمَاجِدُ", "meaning": "صاحب المجد والعظمة والجود والرحمة الفياضة.", "benefit": "ينور وجه صاحبه بالهيبة والوقار والنورانية الروحية."},
    {"name": "الْوَاحِدُ", "meaning": "المنفرد بذاته وصفاته وأفعاله بلا شريك ولا شبيه.", "benefit": "يزيل مخاوف الوحدة والوحشة ويؤنس قلوب الغرباء."},
    {"name": "أورث قناعة النفس والاستغناء والعثور على الحوائج."},
    {"name": "الأَحَدُ", "meaning": "الفرد الذي لم يلد ولم يولد ولم يكن له كفواً أحد.", "benefit": "يكشف الحقائق الروحية ويقوي عقيدة التوحيد بقلب الذاكر."},
    {"name": "الصَّمَدُ", "meaning": "السيد المطاع الذي تصمد وتلجأ إليه الخلائق في حاجاتها.", "benefit": "يبعد حاجة الفقر والعوز للخلق ويقض ديون الذاكر المستعسرة."},
    {"name": "الْقَادِرُ", "meaning": "المتمكن من فعل كل ما يشاء بحكمته وقدرته المطلقة.", "benefit": "يهون الصعاب وينصر المظلوم ويكسر شوكة المتسلطين."},
    {"name": "الْمُقْتَدِرُ", "meaning": "صاحب القدرة العظيمة التي لا يمتنع عليها شيء.", "benefit": "يزيل الكسل والتكاسل عن الطاعات والفرائض الدينية."},
    {"name": "الْمُقَدِّمُ", "meaning": "الذي يقدم الأشياء ويضعها في مواضعها بحسب حكمته.", "benefit": "يورث التقدم والترقي والنجاح في مجالات العلم والعمل."},
    {"name": "الْمُؤَخِّرُ", "meaning": "الذي يؤخر ما يشاء من الأشياء والمخلوقات بحمعرفته.", "benefit": "ينجي من التسرع في اتخاذ القرارات المهلكة ويهدئ النفس والروع."},
    {"name": "الأَوَّلُ", "meaning": "الذي ليس قبله شيء، القديم الأزلي الذي لم يسبق بعدم.", "benefit": "ينفع عند الشروع في السفر والأمور والمهام الصعبة والجديدة."},
    {"name": "الآخِرُ", "meaning": "الباقي بعد فناء خلقه، الدائم بلا نهاية سبحانه.", "benefit": "يؤمن القارئ من خاتمة السوء ويورث الرضا وحب لقاء الله."},
    {"name": "الظَّاهِرُ", "meaning": "الغالب البادي بآياته الكونية وبراهينه العقلية الساطعة.", "benefit": "يكشف الحقائق الغائبة ويقوي البصر والبصيرة وينصر المظلوم."},
    {"name": "الْبَاطِنُ", "meaning": "المحجوب عن الأبصار المحيط ببواطن الأمور وخفاياها.", "benefit": "يورث الخشوع والإخلاص وحب الطاعة ومكافحة الرياء."},
    {"name": "الْوَالِي", "meaning": "المالك للأشياء المتصرف فيها بمفرده وبحكمته.", "benefit": "يحفظ البيوت والأملاك والبلاد من الزلازل والكوارث والفتن الكبرى."},
    {"name": "الْمُتَعَالِي", "meaning": "المنزه عن صفات المخلوقين، العلي عن كل نقص وشبه.", "benefit": "ييسر نيل القبول والوجاهة والرفعة والشرف عند أصحاب النفوذ."},
    {"name": "الْبَرُّ", "meaning": "العطوف المحسن لعباده كثير الإحسان والخير والبر.", "benefit": "ييسر التوفيق لبر الوالدين وصلاح الأبناء والقبول بين الخلق."},
    {"name": "التَّوَّابُ", "meaning": "يقبل توبة عباده المرة تلو الأخرى ويسامح خطاياهم.", "benefit": "يفتح باب التوبة والإنابة الخالصة ويطهر النفس من المعاصي."},
    {"name": "الْمُنْتَقِمُ", "meaning": "الذي يقهر العصاة والظالمين وينكل بهم بعد الإعذار.", "benefit": "ينجي من شرور المتسلطين والأعداء القساة ويرد كيد الظالمين."},
    {"name": "الْعَفُوُّ", "meaning": "الممحو للسيئات الغافر للذنوب والخطايا والصفوح.", "benefit": "يمحو الذنوب والآثام ويجلب عفو الله وستره الجميل بالدارين."},
    {"name": "الرَّؤُوفُ", "meaning": "شديد الرحمة والرأفة بعباده المؤمنين الملطف بهم.", "benefit": "يورث الرأفة واللطف بالقلب ونشر المحبة والسلام بين العباد."},
    {"name": "مَالِكُ الْمُلْكِ", "meaning": "المتصرف في ملكه كيف يشاء ولا راد لقضائه وأمره.", "benefit": "يذهب الفقر والعوز ويغني الذاكر بفضل ربه عن جميع الخلق."},
    {"name": "ذُو الْجَلَالِ وَالإِكْرَامِ", "meaning": "المستحق للتعظيم والإكرام، المنفرد بالجلال والعظمة.", "benefit": "اسم عظيم لإجابة الدعاء وتحقيق المستحيل وتيسير الرزق العاجل."},
    {"name": "الْمُقْسِطُ", "meaning": "العادل المنصف المظلومين من الظالمين في أحكامه.", "benefit": "يزيل تشتت الفكر والوسوسة عند الصلاة ويورث العدالة."},
    {"name": "الْجَامِعُ", "meaning": "الجامع للمتفرقات، والجامع للناس يوم الحساب.", "benefit": "مفيد لجمع شمل الأسرة المتفرقة والعثور على الأشخاص والأشياء الضائعة."},
    {"name": "الْغَنِيُّ", "meaning": "المستغني عن خلقه بذاته وصفاته ولا يحتاج أحداً.", "benefit": "يورث الغنى النفسي والمالي والبركة والنجاح في التجارة."},
    {"name": "الْمُغْنِي", "meaning": "المعطي للغنى والكفاف لمن يشاء من عباده بفضله.", "benefit": "يفتح سبل الأرزاق ويكفي قارئه الحاجة والفقر وسؤال الآخرين."},
    {"name": "الْمَانِعُ", "meaning": "الذي يحمي عباده ويمنع الضرر والبلاء عنهم بحكمته.", "benefit": "يدفع كيد الحاسدين والأشرار ويمنع وقوع الحوادث والمصائب الكبرى."},
    {"name": "الضَّارُّ", "meaning": "الذي يقدر الضر لمن يشاء من العصاة بحسب حكمته.", "benefit": "يدمر طغيان الأعداء والظلمة ويطهر النفوس المعاندة للحق."},
    {"name": "النَّافِعُ", "meaning": "الموصل للنفع والخير والرحمة لمن يشاء من عباده.", "benefit": "يجلب الصحة التامة والبركة والتوفيق للمشروعات التجارية والزراعية."},
    {"name": "النُّورُ", "meaning": "الهادي المنور للسموات والأرض بالحق والهدى والجمال.", "benefit": "ينور القلوب المظلمة، والوجوه بالهيبة والوقار، ويزيل الكآبة."},
    {"name": "الْهَادِي", "meaning": "المرشد لخلقه إلى سبيل الرشاد والحق والنجاة بالدارين.", "benefit": "يهدي الضالين والشباب الحائرين ويفتح سبل الهداية النفسية الراقية."},
    {"name": "الْبَدِيعُ", "meaning": "خالق الأشياء على غير مثال سابق بجمال وإتقان مطلق.", "benefit": "ييسر حل المعضلات الكبرى ونيل الفطنة والإبداع العلمي والفني."},
    {"name": "الْبَاقِي", "meaning": "الدائم البقاء بلا فناء ولا انتهاء المتصف بالخلود المطلق.", "benefit": "يورث الثبات في العمل والصلاح ويبعد مخاوف الزوال والفصل."},
    {"name": "الْوَارِثُ", "meaning": "الباقي بعد فناء خلقه، الذي ترجع إليه الأملاك.", "benefit": "يورث طول العمر مع البركة والصحة والعمل الصالح الوفير."},
    {"name": "الرَّشِيدُ", "meaning": "المرشد الصالح بحكمته بلا معاون، صاحب الرشد المطلق.", "benefit": "ينير العقول لاتخاذ القرارات المصيرية الصحيحة ويقي من الغواية."},
    {"name": "الصَّبُورُ", "meaning": "الحليم الصابر الذي لا يعجل بالعقوبة بل يعفو ويصفح.", "benefit": "يفرغ الصبر والسلوان بقلوب الذاكرين عند المصائب الشديدة الفادحة."},
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredNames = names.where((item) {
      final nameStr = item["name"]!.replaceAll(RegExp(r'[^\u0621-\u064A]'), '');
      final queryClean = searchQuery.replaceAll(RegExp(r'[^\u0621-\u064A]'), '');
      return nameStr.contains(queryClean) || item["meaning"]!.contains(searchQuery);
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // الخلفية الأصلية الفاتحة المريحة
      appBar: AppBar(
        title: Text(
          "أسماء الله الحسنى",
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E293B), // الهيدر الأصلي
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
          children: [
            // شريط البحث الأصلي الفاتح
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9), // الخلفية الأصلية الرمادية الفاتحة
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => searchQuery = val),
                  style: GoogleFonts.cairo(fontSize: 14, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: "ابحث عن اسم من أسماء الله الحسنى...",
                    hintStyle: GoogleFonts.cairo(color: Colors.black38, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            
            // شبكة الأسماء الأصلية الفاتحة
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: filteredNames.length,
                itemBuilder: (context, index) {
                  final item = filteredNames[index];
                  final originalIndex = names.indexOf(item) + 1;
                  
                  return GestureDetector(
                    onTap: () => _showNameDetailsBottomSheet(context, item, originalIndex),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B), // كارت كحلي فخم مثل مواقيت الصلاة والمزيد وفضل الدعاء
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15), // إطار للتحديد
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          // الرقم الترتيبي بالأعلى
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1), // خلفية خفيفة للرقم
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "$originalIndex",
                                style: GoogleFonts.cairo(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                          // الاسم الشريف باللون الأبيض
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Text(
                                item["name"]!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white, // نص أبيض ناصع كما طلب المستخدم
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // منبثق تفاصيل الاسم الشريف الأصلي الفاتح بلمسات برونزية فاخرة
  void _showNameDetailsBottomSheet(BuildContext context, Map<String, String> item, int index) {
    int counter = 0;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white, // خلفية المنبثق البيضاء الأصلية
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      "الاسم الشريف رقم $index",
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: const Color(0xFF8C6D3A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item["name"]!,
                      style: GoogleFonts.cairo(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF8C6D3A), // برونزي ذهبي ملكي
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // بطاقة المعنى الفاتحة
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: Color(0xFF8C6D3A), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                "المعنى والدلالة:",
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: const Color(0xFF8C6D3A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item["meaning"]!,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // بطاقة الفضل والبركات الروحانية الفاتحة
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F4EA), // خلفية خضراء فاتحة مريحة للبركة
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFA3E4D7).withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_outlined, color: Color(0xFF137333), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                "من بركات وخواص الورد بالاسم الشريف:",
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: const Color(0xFF137333),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item["benefit"]!,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: const Color(0xFF137333),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // عداد الورد التفاعلي الأصلي
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "عَدّاد الورد الخاص بالاسم",
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    "$counter",
                                    style: GoogleFonts.cairo(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF8C6D3A),
                                    ),
                                  ),
                                  Text(
                                    " مرة",
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // زر تصفير العداد
                              IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.black38),
                                onPressed: () {
                                  setModalState(() {
                                    counter = 0;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              // زر التسبيح والورد التفاعلي
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8C6D3A),
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(16),
                                  elevation: 2,
                                ),
                                onPressed: () {
                                  setModalState(() {
                                    counter++;
                                  });
                                  HapticFeedback.lightImpact();
                                },
                                child: const Icon(Icons.add, color: Colors.white, size: 24),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}


