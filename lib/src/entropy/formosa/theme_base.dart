import 'dart:collection';

/// Theme implementation compatible with formosa requirements.
///
/// Formosa theme implementation which wraps the theme information, from
/// stored theme files, into one that is compatible for [Formosa] class.
class ThemeBase<K extends String, V> extends MapBase<String, dynamic> {
  static const String fillSequenceKey = 'FILLING_ORDER';
  static const String naturalSequenceKey = 'NATURAL_ORDER';
  static const String leadsKeyword = 'LEADS';
  static const String ledKeyword = 'LED_BY';
  static const String totalsKeyword = 'TOTAL_LIST';
  static const String imageKeyword = 'IMAGE';
  static const String mappingKeyword = 'MAPPING';
  static const String bitsKeyword = 'BIT_LENGTH';

  // Using [_internalMap] to access the super class of the [FormosaTheme],
  // and using [this] to access the extended attributes and methods.
  final Map<String, dynamic> _internalMap;

  /// Create and initialize a [ThemeBase] instance.
  ///
  /// Returns [ThemeBase] instance based on the provided [themeData].
  const ThemeBase({required Map<K, V> themeData}) : _internalMap = themeData;

  /// Returns a list of words in restriction sequence to form a sentence.
  List<String> get fillingOrder {
    List<String> fillingOrderList = [];

    if (this[fillSequenceKey] != null) {
      fillingOrderList = this[fillSequenceKey];
    }

    return fillingOrderList;
  }

  /// Returns list of words which correspond to key [imageKeyword]
  /// from inner dictionary.
  List get image {
    List image;

    if (containsKey(imageKeyword)) {
      image = this[imageKeyword];
    } else {
      image = [];
    }

    return image;
  }

  /// The keys of this [ThemeBase].
  ///
  /// The returned iterable has efficient length and contains operations,
  /// based on [length] and [containsKey] of the [ThemeBase].
  ///
  /// The order of iteration is defined by the individual Map implementation,
  /// but must be consistent between changes to the [ThemeBase].
  ///
  /// Modifying the map while iterating the keys may break the iteration.
  @override
  Iterable<String> get keys => _internalMap.keys;

  /// Returns list of words which correspond to key [leadsKeyword] from
  /// the current theme type.
  List get leads {
    List ledList;

    if (containsKey(leadsKeyword)) {
      ledList = this[leadsKeyword];
    } else {
      ledList = [];
    }

    return ledList;
  }

  /// Returns word that leads the current theme type.
  String get ledBy {
    var ledBy_ = (this[ledKeyword] != null) ? this[ledKeyword] : '';
    return ledBy_.toString();
  }

  /// Returns list of words which correspond to key [mappingKeyword]
  /// from the current theme type.
  ThemeBase get mapping {
    ThemeBase mapping;

    if (containsKey(mappingKeyword)) {
      mapping = this[mappingKeyword];
    } else {
      mapping = ThemeBase(themeData: {});
    }

    return mapping;
  }

  /// Returns list of indexes in filling order.
  List<int> get naturalMap {
    List<int> result = [];
    var fillingWords_ = fillingOrder;
    for (String word in fillingWords_) {
      result.add(naturalIndex(word));
    }
    return result;
  }

  /// Returns list of words which correspond to key [naturalSequenceKey]
  /// from the current theme type.
  List<String> get naturalOrder {
    List<String> naturalOrder_;

    if (containsKey(naturalSequenceKey)) {
      naturalOrder_ = this[naturalSequenceKey];
    } else {
      naturalOrder_ = [];
    }

    return naturalOrder_;
  }

  /// The value for the given [key], or new instance [ThemeBase] if [key]
  /// is not in the [ThemeBase] or it is a [Map].
  @override
  operator [](Object? key) {
    if (_internalMap[key] == null) {
      return ThemeBase(themeData: <String, dynamic>{});
    } else if (_internalMap[key] is Map<String, dynamic>) {
      return ThemeBase(themeData: _internalMap[key]);
    } else {
      return _internalMap[key];
    }
  }

  /// Associate the [key] with the given [value].
  ///
  /// If the [key] was already in the [ThemeBase], its associated [value]
  /// is changed. Otherwise, the value/key pair is added to [ThemeBase].
  ///
  /// If the [value] is of type [Map] type, if is converted to [ThemeBase]
  /// type before it is associated to the [key].
  @override
  void operator []=(String key, dynamic value) {
    if (value is Map<K, dynamic>) {
      _internalMap[key] = ThemeBase(themeData: value);
    } else {
      _internalMap[key] = value;
    }
  }

  /// Building words using [dataBits], following the filling order of the
  /// theme data. Returns the resulting words ordered as sentence in natural
  /// language.
  List<String> assembleSentence(String dataBits) {
    int bitIndex = 0;
    List<String> fillingOrderList = fillingOrder;
    List<String> currentSentence = List.filled(fillingOrderList.length, '');

    for (var syntacticKey in fillingOrderList) {
      int bitLength = this[syntacticKey].bitLength();

      // Integer from substring of zeroes and ones representing index of
      // current word within its list
      int wordIndex = int.parse(
        dataBits.substring(bitIndex, bitIndex + bitLength),
        radix: 2,
      );
      bitIndex += bitLength;

      var listOfWords = getLeadList(syntacticKey, currentSentence);
      var syntacticOrder = naturalIndex(syntacticKey);

      currentSentence[syntacticOrder] = listOfWords[wordIndex];
    }
    return currentSentence;
  }

  /// Returns the number of bits which correspond to bits keyword in the
  /// theme type.
  int bitLength() {
    if (this[bitsKeyword] == null) {
      return 0;
    } else {
      return this[bitsKeyword];
    }
  }

  /// Returns list of bit lengths for each phrase in default theme. Each
  /// phrase in default theme is retrieved using [fillSequenceKey] as key
  /// for inner dictionary.
  List<int> bitsFillSequence() {
    List<int> result = [];
    var filingWords = fillingOrder;

    for (String word in filingWords) {
      result.add(this[word].bitLength());
    }

    return result;
  }

  /// Returns number of bits dedicated for each phrase in theme type.
  int bitsPerPhrase() {
    var filingWords = fillingOrder;
    int sum = 0;

    for (String word in filingWords) {
      sum += this[word].bitLength() as int;
    }

    return sum;
  }

  /// Removes all entries from the [ThemeBase].
  ///
  /// After this, the [ThemeBase] is empty.
  @override
  void clear() {
    _internalMap.clear();
  }

  /// Returns the index of the word in the natural speech sentence of
  /// a given [syntacticWord].
  int fillIndex(String syntacticWord) {
    List<String> fillingWords_ = fillingOrder;
    return fillingWords_.indexOf(syntacticWord);
  }

  /// Returns the indexes of the sentence in natural speech of a given
  /// theme type.
  List<int> fillingMap() {
    List<int> result = [];
    var naturalWords_ = naturalOrder;
    for (String word in naturalWords_) {
      result.add(fillIndex(word));
    }
    return result;
  }

  /// Returns the indexes of a sentence from the lists ordered as the filling
  /// order of this theme type. The sentence can be given as a list or a
  /// string. Throws [ArgumentError] if sentence is not complete.
  List<int> getFillingIndexes(dynamic sentence) {
    if (sentence is String) sentence = sentence.split(' ');

    if ((sentence.length % wordsPerPhrase()) != 0) {
      throw ArgumentError(
        'The number of words in sentence must be $wordsPerPhrase(),'
        ' but it is ${sentence.length}',
      );
    }

    List<int> result = [];
    var wordNaturalIndexes_ = getNaturalIndexes(sentence);
    var naturalMap_ = naturalMap;
    for (int index in naturalMap_) {
      result.add(wordNaturalIndexes_[index]);
    }

    return result;
  }

  /// Returns a list of words led by [syntacticKey] the underline theme type.
  ///
  /// If [ThemeBase] doesn't have words with key [fillSequenceKey] then
  /// the list of the words defined in [sentence] will be used.
  List getLeadList(String syntacticKey, List sentence) {
    var leadList = [];
    var primeSyntacticList_ = primeSyntacticLeads();

    if (primeSyntacticList_.contains(syntacticKey)) {
      leadList = this[syntacticKey].totalWords();
    } else {
      var mapping = getLeadMapping(syntacticKey);
      var leadingWord_ = sentence[getLedByIndex(syntacticKey)];
      leadList = mapping[leadingWord_];
    }

    return leadList;
  }

  /// Returns instance of [ThemeBase] class that led by the [ledBy]
  /// leading word.
  ThemeBase getLeadMapping(String ledBy) {
    return this[this[ledBy].ledBy][ledBy].mapping;
  }

  /// Returns the natural index of the leading word [syntacticKey].
  int getLedByIndex(String syntacticKey) {
    return naturalIndex(this[syntacticKey].ledBy);
  }

  /// Returns a new class of [ThemeBase] for the mapping of the leading
  /// word [ledByWord] string as a key.
  ThemeBase getLedByMapping(String ledByWord) {
    String syntacticLeads_ = this[ledByWord].ledBy;
    return this[syntacticLeads_][ledByWord].mapping;
  }

  /// Returns the indexes of a sentence from the lists ordered as natural
  /// speech of this theme. Throws [ArgumentError] if number of words in
  /// sentence is not correct.
  List<int> getNaturalIndexes(dynamic sentence) {
    if (sentence is String) sentence = sentence.split(' ');

    if (sentence.length != wordsPerPhrase()) {
      throw ArgumentError(
        'The number of words in sentence must be $wordsPerPhrase(),'
        ' but it is ${sentence.length}',
      );
    }

    List<int> wordIndexes = List.filled(sentence.length, 0);
    var restrictionSequence_ = restrictionSequence();
    var primeSyntacticLeads_ = primeSyntacticLeads();
    var restrictionPairs_ = restrictionPairs(sentence);

    List<(dynamic, dynamic)> restrictionRelation = [];
    for (int idx = 0; idx < restrictionSequence_.length; idx++) {
      restrictionRelation.add(
        (restrictionSequence_[idx], restrictionPairs_[idx]),
      );
    }

    for (var eachSyntacticLeads in primeSyntacticLeads_) {
      var eachRelation =
          (eachSyntacticLeads, sentence[naturalIndex(eachSyntacticLeads)]);
      var mnemoIndex = getRelationIndexes(eachRelation).$1;
      var wordIndex = getRelationIndexes(eachRelation).$2;
      wordIndexes[mnemoIndex] = wordIndex;
    }

    for (var eachRelation in restrictionRelation) {
      var mnemoIndex = getRelationIndexes(eachRelation).$1;
      var wordIndex = getRelationIndexes(eachRelation).$2;
      wordIndexes[mnemoIndex] = wordIndex;
    }
    return wordIndexes;
  }

  /// Returns the amount of phrases in [formosa].
  int getPhraseAmount(dynamic formosa) {
    if (formosa is String) formosa = formosa.split(' ');

    var formosaSize_ = formosa.length;
    var phraseSize_ = wordsPerPhrase();

    var phraseAmount_ = (formosaSize_ / phraseSize_);

    return phraseAmount_.round();
  }

  /// Returns indexes of [formosa] from each sentence in it.
  List<int> getPhraseIndexes(dynamic formosa) {
    if (formosa is String) formosa = formosa.split(' ');

    List<int> indexes = [];
    List<List<String>> sentences = getSentences(formosa);

    for (dynamic eachPhrase in sentences) {
      for (int eachFillIndex in getFillingIndexes(eachPhrase)) {
        indexes.add(eachFillIndex);
      }
    }
    return indexes;
  }

  /// Get the indexes from a given [relation].
  ///
  /// [relation] is the given relation to find the index from the lists.
  /// It can be whether a [Record] of (syntactic leads and the formosa leads
  /// or a [Record] of (tuples of syntactic leads and led and formosa leads
  /// and led). For example, ("VERB", word_verb) or
  /// (("VERB", "SUBJECT"), (word_verb, word_subject)).
  ///
  /// Returns the indexes from a given [relation]. If any given words only
  /// leads and not led, finds the indexes in the [FormosaTheme.totalWords()]
  /// list.
  (int, int) getRelationIndexes((dynamic, dynamic) relation) {
    var syntacticRelation = relation.$1;
    var formosaRelation = relation.$2;

    // If argument is type of Record(String, String)
    if (syntacticRelation is String && formosaRelation is String) {
      var syntacticLeads_ = syntacticRelation;
      var mnemoLeads = formosaRelation;
      var wordsList = this[syntacticLeads_].totalWords();
      var mnemoIndex = naturalIndex(syntacticRelation);
      var wordIndex = wordsList.indexOf(mnemoLeads);

      return (mnemoIndex, wordIndex);
    }
    // If argument is (Record, Record)
    else {
      String syntacticLeads_ = syntacticRelation.$1;
      String syntacticLed_ = syntacticRelation.$2;
      String mnemoLeads = formosaRelation.$1;
      String mnemoLed = formosaRelation.$2;
      int mnemoIndex = naturalIndex(syntacticLed_);
      ThemeBase restrictionDict =
          this[syntacticLeads_][syntacticLed_].mapping;
      List<String> wordsList = List<String>.from(restrictionDict[mnemoLeads]);
      var wordIndex = wordsList.indexOf(mnemoLed);

      return (mnemoIndex, wordIndex);
    }
  }

  /// Returns list of sentences of given [formosa].
  List<List<String>> getSentences(dynamic formosa) {
    if (formosa is String) formosa = formosa.split(' ');

    // Prepare variables for generating list of sentences
    var phraseSize_ = wordsPerPhrase();
    var phraseAmount_ = getPhraseAmount(formosa);

    // Generate sentence for specific formosa
    List<List<String>> sentences = List.generate(
      phraseAmount_,
      (int eachPhrase) {
        int start = phraseSize_ * eachPhrase;
        int end = phraseSize_ * (eachPhrase + 1);
        return formosa.sublist(start, end);
      },
    );
    return sentences;
  }

  /// Returns formosa sentences in the natural speech order from [dataBits].
  List getSentencesFromBits(String dataBits) {
    String data;
    int bitsPerPhrase_ = bitsPerPhrase();
    int phrasesAmount = dataBits.length ~/ bitsPerPhrase_;

    List<String> sentences = [];
    for (int phraseIndex = 0; phrasesAmount > phraseIndex; phraseIndex++) {
      int sentenceIndex = bitsPerPhrase_ * phraseIndex;
      data = dataBits.substring(sentenceIndex, sentenceIndex + bitsPerPhrase_);
      sentences.addAll(assembleSentence(data));
    }

    return sentences;
  }

  /// Returns sentence index in the natural speech of a given [syntacticWord].
  int naturalIndex(String syntacticWord) {
    List<String> naturalWords_ = naturalOrder;
    return naturalWords_.indexOf(syntacticWord);
  }

  /// Creates and returns the list of syntactic words which does
  /// not follow any other syntactic word.
  List<String> primeSyntacticLeads() {
    List<String> result = [];
    List<String> fillingWords_ = fillingOrder;
    for (String word in fillingWords_) {
      if (this[word].ledBy == 'NONE') {
        result.add(word);
      }
    }
    return result;
  }

  /// Removes [key] and its associated value, if present, from the [ThemeBase].
  ///
  /// Returns the value associated with key before it was removed.
  /// Returns null if key was not in the [ThemeBase].
  @override
  V remove(Object? key) {
    return _internalMap.remove(key);
  }

  /// Creates and return the list of records for restriction sequence in
  /// natural speech which is defined by [leadsKeyword].
  List<(int, int)> restrictionIndexes() {
    List<(int, int)> result = [];
    List<(String, String)> restrictionSeq_ = restrictionSequence();
    for ((String, String) record in restrictionSeq_) {
      result.add((naturalIndex(record.$1), naturalIndex(record.$2)));
    }
    return result;
  }

  /// Creates and returns the list of restriction records
  /// from a given [sentence].
  List<(String, String)> restrictionPairs(List<String> sentence) {
    List<(int, int)> indexes = restrictionIndexes();
    List<(String, String)> result = [];
    for ((int, int) element in indexes) {
      result.add((sentence[element.$1], sentence[element.$2]));
    }
    return result;
  }

  /// Returns list of restrictions used in default theme.
  List<(String, String)> restrictionSequence() {
    List<(String, String)> result = [];
    var filingWords_ = fillingOrder;
    for (String word in filingWords_) {
      var leadsBy_ = this[word].leads;
      for (String restrictionWord in leadsBy_) {
        result.add((word, restrictionWord));
      }
    }
    return result;
  }

  /// Returns list of words which correspond to key [totalsKeyword]
  /// from current theme data.
  List<String> totalWords() {
    List<String> temp = [];
    _internalMap.forEach(
      (key, value) {
        if (key == totalsKeyword) {
          temp.addAll(List<String>.from(_internalMap[key]));
        } else {
          if (value is Map && value[totalsKeyword] != null) {
            temp.addAll(List<String>.from(value[totalsKeyword]));
          }
        }
      },
    );
    if (temp.isEmpty) {
      temp.add(' ');
    }
    return temp;
  }

  /// Returns list of words used in default theme.
  List<String> wordList() {
    List<String> result = [];
    var filingWords_ = fillingOrder;
    // Iterate through all phrases in theme.
    for (String word in filingWords_) {
      result.addAll(this[word].totalWords());
    }
    // Removes duplicate words from list.
    return result.toSet().toList();
  }

  /// The [wordsPerPhrase] method returns length of words which can be
  /// accessed by [fillSequenceKey] in inner dictionary. If theme is malformed, 0 is returned.
  int wordsPerPhrase() {
    int wordsPerPhrase_ = fillingOrder.length;
    int wordsNaturalOrder_ = naturalOrder.length;

    if (wordsPerPhrase_ != wordsNaturalOrder_) {
      // Theme is malformed.
      throw 'Theme is malformed!';
    }

    return wordsPerPhrase_;
  }
}
