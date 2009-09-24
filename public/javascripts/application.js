function updateTagControl(thing_id){
    var ext=$('tags_ext_'+thing_id);
    var tags=$('tags_'+thing_id)
    if(tags.empty()){
        ext.show()
    }else{
        ext.hide();
    }
}