importScripts('/vendor/lodash.min.js');

var lunrConfig = {
	"limit": 5,
} ;

var removeAccents = function (builder) {

  var pipelineFunction = function (token) {
      return token.update(function () { return _.deburr(token) })
  } ;

  // Register the pipeline function so the index can be serialised
  lunr.Pipeline.registerFunction(pipelineFunction, 'removeAccents')

  // Add the pipeline function to both the indexing pipeline and the
  // searching pipeline
  builder.pipeline.before(lunr.stemmer, pipelineFunction)
  builder.searchPipeline.before(lunr.stemmer, pipelineFunction)
}

var lunrPlugins = [
	function () {
		this.ref('id');
		this.field('link');
		this.field('title');
		this.field('content');
		this.field('summary');
		this.field('status');
		this.field('authors');
		this.field('tags');
	} ,
	removeAccents ,
] ;
