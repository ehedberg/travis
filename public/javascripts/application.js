// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var _TRAVIS_DEBUG = false; 

function updateStory(basePath, story, onSuccessCallback, onFailCallback) {
	_tdebug("Update Story " + story.id);

	var postHash = new Hash();
	postHash.set('method',"put");
	postHash.set('action',"update");
	postHash.set('id',story.id.toString());
	postHash.set('controller', "stories")
	
	var storyQS = new String();
	var keys = Object.keys(story);
	var vals = Object.values(story);
	
	for(var i=0; i<keys.length;i++)
	{
		_tdebug(keys[i]+ ": " + vals[i]);
		if(keys[i] != "id" && keys[i] != "state")
		{
			storyQS += "story["+keys[i]+"]="+vals[i];

			if(i < keys.length-1)
				storyQS+="&";
		}
	}
	
	postHash.set('story', storyQS);
	var mainPostTmp = new Template("_method=#{method}&action=#{action}&id=#{id}&controller=#{controller}&#{story}");//
	_tdebug(mainPostTmp.evaluate(postHash));
	_tdebug(postHash.inspect())


	_tdebug(basePath+"stories/"+story.id);
	new Ajax.Request(basePath+"stories/"+story.id, {
			method:'Post',
			parameters: mainPostTmp.evaluate(postHash),
			onSuccess: onSuccessCallback,
			onFailure: onFailCallback
			}
		);
}


function resetInterationSwag(controllerPath)
{
  if(confirm("This will reset the all the stories for this iteration to a swag of ZERO"))
  {
    new Ajax.Request(controllerPath+'.json', { method: 'get',
      onSuccess: function(response) {
        var iteration = response.responseJSON.iteration;
		_tdebug(iteration.toString())
        _tdebug(iteration.title)
        for(var i=0; i < iteration.stories.length; i++) {
			if(iteration.stories[i].state == "new")
			{
				iteration.stories[i].swag = "";
			  	updateStory(getBasePath(controllerPath, "iterations"), iteration.stories[i], succcessfullCall, failedCall);
			}
        }
      }
    });
  }
}

function getBasePath(path, key)
{
	return path.substring(0, path.indexOf(key));
}

function failedCall(response)
{
	_tdebug("Ajax call failed");
}

function succcessfullCall(response)
{
	_tdebug("Ajax call success");
	window.location.reload();
}

function _tdebug(msg)
{
	if(_TRAVIS_DEBUG)
		console.log(msg);
}