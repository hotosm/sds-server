class OsmShadowsController < ApplicationController
   before_filter :authenticate,  :only => [:index, :show, :list, :new, :edit, :create, :destroy]
   before_filter :change_project, :only => [:show, :list, :new, :edit]
   before_filter :admin_user,   :only => [:destroy]
   before_filter :find_project
   before_filter :filter_tag_params, :only => [:create, :update]

   require 'xml/libxml'
   require 'pp'

   def index
      redirect_to tagsearch_path
   end


   def show
      retrieve_object
      @title = t"osm_shadows.show.title", :id => @osm_shadow.id
   end

   def list
      @title = t"osm_shadows.list.title", :type => params[:osm_type], :osmid => params[:osm_id]
      
      retrieve_objects
      
      if (@osm_shadow.nil?) then
         @osm_shadow = OsmShadow.new
         @osm_shadow.osm_type = params[:osm_type]
         @osm_shadow.osm_id = params[:osm_id]
         @tags = Array.new
         @taghash = Hash.new
      end
      
      if params['zoom']
         current_user.zoom = params['zoom'] || 0
         current_user.lon  = params['lon'] || 0
         current_user.lat  = params['lat'] || 0
         current_user.save!
      end
   end


   def edit 
      @title = t"osm_shadows.edit.title"
      retrieve_object
   end


   def new
      @title = t"osm_shadows.new.h1"

      @osm_shadow = OsmShadow.new
      @osm_shadow.osm_type = params[:osm_type]
      @osm_shadow.osm_id = params[:osm_id]
      @tags = Array.new
      @taghash = Hash.new
   end


   def update
      if (!current_changeset.nil?) then
         changeset = current_changeset
      elsif (!current_user.nil?) then
         changeset = Changeset.new
         changeset.user_id = current_user.id
         changeset.save!
         store_changeset(changeset)
      end
      params['osm_shadow']['changeset_id'] = changeset.id
      
      shadow = OsmShadow.find(params[:id])
      shadow.changeset = changeset
      
       if shadow.update_attributes!(params["osm_shadow"])
         redirect_to(shadow, :notice => t("notice.record_updated"))
       else
         redirect_to({:action => :edit}, {:alert => t("alert.record_not_updated")})
       end

   end

   def create
   
      if (!current_changeset.nil?) then
         changeset = current_changeset
      elsif (!current_user.nil?) then
         changeset = Changeset.new
         changeset.user_id = current_user.id
         changeset.save!
         store_changeset(changeset)
      end
      params['osm_shadow']['changeset_id'] = changeset.id
      
      @osm_shadow = OsmShadow.new(params['osm_shadow'])
      
      if @osm_shadow.save
         redirect_to(@osm_shadow, :notice => t("notice.record_saved"))
      else
         @tags = Array.new
         @taghash = Hash.new
         render :action => "new", :alert => t("alert.record_not_saved")
      end
   end


   def destroy
      @osm_shadow = OsmShadow.find(params[:id])
      @osm_shadow.destroy
      
      redirect_to(list_shadows_url(:osm_type => @osm_shadow.osm_type, :osm_id=>@osm_shadow.osm_id), {:notice => t("notice.record_deleted") })
   end

private

   #filters params to remove any tags from projects the user does not have access to
   def filter_tag_params
     if params["osm_shadow"]["tags_attributes"]
       allowed_tag_keys = current_user.find_visible_tag_keys
       tags_attributes = params["osm_shadow"].delete("tags_attributes")
       
       tags_attributes.each do |tag_attr|
         tags_attributes.delete(tag_attr[0]) unless allowed_tag_keys.include?(tag_attr[1]["key"])
       end

       params["osm_shadow"]["tags_attributes"] = tags_attributes
     end
   end

   def retrieve_object
      @osm_shadow = OsmShadow.find(params[:id])

      @tags = Array.new
      @taghash = Hash.new
      @visible_tag_keys = current_user.find_visible_tag_keys
  
      if (!@osm_shadow.nil?) then
         @osm_shadow.tags.each do |tag|
              @tags.push(tag)
              @taghash[tag.key] = tag.value
           end
        end
      end

   def retrieve_objects
      @osm_shadows = OsmShadow.where("osm_type = ? and osm_id = ?",  params[:osm_type], params[:osm_id]).order("created_at ASC")
      @osm_shadow = @osm_shadows.first
      @visible_tag_keys = current_user.find_visible_tag_keys
   end

end
