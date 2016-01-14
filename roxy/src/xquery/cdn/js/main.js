 GTE.concepts = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  highlight: true,
  hint: true,
  limit: 15,
  prefetch: {
    url: '/gte20/concept/getLabels.xqy',
  }
});
 
GTE.concepts.initialize();
 
$('.typeahead').typeahead(null, {
  name: 'concepts',
  displayKey: 'name',
  source: GTE.concepts.ttAdapter()
});