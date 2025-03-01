@urlQuery = new Array()
checkUserSigned = (context, redirect) ->
	if Meteor.userId()
		Creator.pushCurrentPathToUrlQuery();
		# Meteor.defer(Favorites.changeState);
		app_id = context.params.app_id
		if (app_id != "-") && app_id && Session.get("app_id") != app_id
			Session.set("app_id", app_id)
	return
	# listTreeCompany = localStorage.getItem("listTreeCompany")
	# if listTreeCompany
	# 	Session.set('listTreeCompany', listTreeCompany);
	# else
	# 	# 从当前用户的space_users表中获取
	# 	s_user = db.space_users.findOne()
	# 	if s_user?.company
	# 		localStorage.setItem("listTreeCompany", s_user?.company)
	# 		Session.set('listTreeCompany', s_user?.company);
	# 	else
	# 		# Session.set('listTreeCompany', "-1");
	# 		Session.set('listTreeCompany', "xZXy9x8o6qykf2ZAf");
	# 统一设置此参数，待以后拆分
	# Session.set('listTreeCompany', "xZXy9x8o6qykf2ZAf")
	
	# if !Meteor.userId()
	# 	Setup.validate();

set_sessions = (context, redirect)->
	
	oldObjectName = Tracker.nonreactive ()-> return Session.get("object_name")
	oldRecordId = Tracker.nonreactive ()-> return Session.get("record_id")
	object_name = context.params.object_name
	record_id = context.params.record_id
	Session.set("object_name", object_name)
	Session.set("tab_name", null)
	Session.set("pageApiName", null)
	# 手机上record_id从老值变更为新值时，要清除record，否则list组件不会处理加载
	# if record_id != oldRecordId
	# 	Template.creator_view.currentInstance?.record?.set(null)
	Session.set("record_id", record_id)
	Session.set("record_name", null)
	# objectHomeComponent = BuilderCreator.pluginComponentSelector(BuilderCreator.store.getState(), "ObjectHome", object_name)
	# if objectHomeComponent
	# 	Session.set("object_home_component", object_name);
	# else
	# 	Session.set("object_home_component", null)
	if record_id and ((oldObjectName and oldObjectName != object_name) or (oldRecordId and record_id != oldRecordId))
		# 切换object_name且是详细界面，说明是点击进入了相关详细记录界面，强制加一条临时导航栏项
		Session.set("temp_navs_force_create", true)

checkAppId = (context, redirect)->
	app_id = context.params.app_id
	if app_id == "admin" and Steedos.isMobile()
		# 手机上不支持admin应用，直接跳转到用户设置界面
		redirect "/user_settings"
		# urlQuery.pop的原因是手机上user_settings界面返回按钮应该正常返回到上个界面而不是返回到/app/admin
		urlQuery.pop()

FlowRouter.route '/app',
	triggersEnter: [ checkUserSigned ],
	action: (params, queryParams)->
		BlazeLayout.render Creator.getLayout(),
			main: "creator_app_home"

FlowRouter.route '/app/menu',
	triggersEnter: [ checkUserSigned ],
	action: (params, queryParams)->
		main = 'app_object_menu'
		Session.set("hidden_header",true)
		BlazeLayout.render Creator.getLayout(),
			main: main
	triggersExit: [(context, redirect) ->
		if Steedos.isMobile()
			Session.set("hidden_header", undefined)
	]

FlowRouter.route '/app/:app_id',
	triggersEnter: [ checkUserSigned ],
	action: (params, queryParams)->
		app_id = FlowRouter.getParam("app_id")
		if (app_id != "-")
			# 切换APP时先清除object_name，record_id，否则相关依赖的autorun会以之前错误的值运行
			Session.set("object_name", null)
			Session.set("record_id", null)
			Session.set("app_id", app_id)
		Session.set("admin_template_name", null)
		app = Creator.getApp(app_id)
		if app and app.is_use_iframe
			main = 'creator_app_iframe'
		else
			main = 'creator_app_home'
		BlazeLayout.render Creator.getLayout(),
			main: main

FlowRouter.route '/app/admin/page/:template_name',
	triggersEnter: [ checkUserSigned ],
	action: (params, queryParams)->
		template_name = params?.template_name
		if Meteor.userId()
			Session.set("app_id", "admin")
			Session.set("admin_template_name", template_name)
			BlazeLayout.render Creator.getLayout(),
				main: template_name

FlowRouter.route '/app/:app_id/page/:page_id',
	triggersEnter: [ checkUserSigned ],
	action: (params, queryParams)->
		console.log('params', params)
		app_id = FlowRouter.getParam("app_id")
		page_id = params?.page_id
		Session.set("pageApiName", page_id)
		Session.set("object_name", null)
#		setTimeout(()->
#			SteedosUI.render(stores.ComponentRegistry.components.PublicPage, { token: page_id }, $(".empty-template-root")[0])
#		, 50)
		BlazeLayout.render Creator.getLayout(),
			main: 'page_template'
			regions: {
				appId: app_id,
				pageId: page_id
			};
	triggersExit: [(context, redirect) ->
		Session.set("pageApiName", null)
	]

FlowRouter.route '/page/:page_id/',
	action: (params, queryParams)->
		BlazeLayout.render Creator.getLayout(),
			main: 'page'

# FlowRouter.route '/app/:app_id/instances/grid/:listview_id',
# 	triggersEnter: [ checkUserSigned ],
# 	action: (params, queryParams)->
# 		app_id = FlowRouter.getParam("app_id")
# 		if (app_id != "-")
# 			Session.set("app_id", app_id)
# 		Session.set("object_name", "instances")
# 		FlowRouter.go '/workflow'
# 		return

# FlowRouter.route '/app/:app_id/instances/view/:record_id',
# 	triggersEnter: [ checkUserSigned ],
# 	action: (params, queryParams)->
# 		instanceId = FlowRouter.getParam("record_id")
# 		uobj = {}
# 		uobj['X-User-Id'] = Meteor.userId()
# 		uobj['X-Auth-Token'] = Accounts._storedLoginToken()
# 		data = {
# 			object_name: "",
# 			record_id: "",
# 			space_id: Session.get("spaceId")
# 		}
# 		url = Steedos.absoluteUrl() + ("api/workflow/view/" + instanceId + "?") + $.param(uobj)
# 		data = JSON.stringify(data)
# 		$(document.body).addClass('loading')
# 		$.ajax({
# 			url: url,
# 			type: 'POST',
# 			async: true,
# 			data: data,
# 			dataType: 'json',
# 			processData: false,
# 			contentType: 'application/json',
# 			success:  (responseText, status) -> 
# 				$(document.body).removeClass('loading')
# 				if responseText.errors
# 					responseText.errors.forEach (e) -> 
# 						toastr.error(e.errorMessage)
# 					# Template.creator_view.currentInstance.onEditSuccess()
# 					return
# 				else if responseText.redirect_url
# 					if Meteor.settings.public.webservices?.workflow?.url
# 						Steedos.openWindow(responseText.redirect_url);
# 					else
# 						Steedos.openWindow(Steedos.absoluteUrl(responseText.redirect_url));
# 			,
# 			error:  (xhr, msg, ex) -> 
# 				$(document.body).removeClass('loading')
# 				toastr.error(msg)
# 				# Template.creator_view.currentInstance.onEditSuccess()
# 		})

FlowRouter.route '/app/:app_id/tab_iframe/:tab_id',
	triggersEnter: [ checkUserSigned ],
	action: (params, queryParams)->
		tab_id = FlowRouter.getParam("tab_id")
		Session.set("tab_name", tab_id)
		Session.set("object_name", null)
		BlazeLayout.render Creator.getLayout(),
			main: "page_iframe"
			regions: {
				params: params,
				queryParams: queryParams
			}
	triggersExit: [(context, redirect) ->
		Session.set("tab_name", null)
	]

objectRoutes = FlowRouter.group
	prefix: '/app/:app_id/:object_name',
	name: 'objectRoutes',
	triggersEnter: [checkUserSigned, set_sessions]

objectRoutes.route '/',
	triggersEnter: [ 
		# 自动跳转到对象的第一个视图
		(context, redirect) -> 
			object_name = context.params.object_name
			listview = window.getFirstListView(object_name)
			# console.log("getFirstListView listview",listview)
			list_view_id = listview?.name || listview?._id
			app_id = context.params.app_id
			url = "/app/" + app_id + "/" + object_name + "/grid/" + list_view_id
			redirect(url)
	 ],
	action: (params, queryParams)->
		BlazeLayout.render Creator.getLayout(),
			main: "object_home"

objectRoutes.route '/:record_id/:related_object_name/grid',
	action: (params, queryParams)->
		app_id = Session.get("app_id")
		object_name = FlowRouter.getParam("object_name")
		record_id = FlowRouter.getParam("record_id")
		related_object_name = FlowRouter.getParam("related_object_name")
		data = {app_id: app_id, object_name: object_name, record_id: record_id, related_object_name: related_object_name}
		Session.set 'related_object_name', related_object_name
		
		main = "related_object_list"
		page = Steedos.Page.getPage('related_list', app_id, related_object_name);
		if page
			main = "page_related_list_view"
			regions = {
				page: page,
				appId: Session.get("app_id"),
				objectName: object_name,
				recordId: record_id,
				relatedObjectName: related_object_name,
				__timestamp: new Date().getTime()
			};

		Meteor.setTimeout ()->
			BlazeLayout.render Creator.getLayout(),
				main: main,
				regions: regions
		, 10

objectRoutes.route '/view/:record_id',
	action: (params, queryParams)->
		# console.log('objectRoutes=====>/view/:record_id', )
		if queryParams["X-Space-Id"]
			Steedos.setSpaceId(queryParams["X-Space-Id"])
		app_id = FlowRouter.getParam("app_id")
		object_name = FlowRouter.getParam("object_name")
		record_id = FlowRouter.getParam("record_id")
		data = {app_id: app_id, object_name: object_name, record_id: record_id}
		ObjectRecent.insert(object_name, record_id)
		Session.set("detail_info_visible", true)
		main = "creator_view"
		page = Steedos.Page.getPage('record', Session.get("app_id"), object_name, record_id);
		if page
			main = "page_object"
			regions =  window._.defaultsDeep({display: Steedos.Page.getDisplay(object_name)}, FlowRouter.current().queryParams , {
				page: page,
				appId: Session.get("app_id"),
				recordId: record_id,
				objectName: object_name,
				pageType: "record",
				__timestamp: new Date().getTime()
			});;
		# console.log('/view/:record_id regions===>', regions)			
		Meteor.setTimeout ()->
			BlazeLayout.render Creator.getLayout(),
				main: main
				regions: regions
		, 10
	triggersExit: [
		(context, redirect) ->
			if Session.get("instance_change") && ((context.params?.object_name == 'instances' && context.queryParams?.side_listview_id == 'draft') || (context.params?.object_name == 'instance_tasks' && context.queryParams?.side_listview_id == 'inbox'))
				InstanceManager.saveIns(false);
	]
objectRoutes.route '/grid/:list_view_id',
	action: (params, queryParams)->
		Session.set("record_id", null)
		# 每次进视图应该把过滤器关联的视图及对象清空，否则有bug：刷新浏览器时过滤器中已保存条件未能显示出来 #1167
		if Session.get("object_name") != FlowRouter.getParam("object_name") or Session.get("list_view_id") != FlowRouter.getParam("list_view_id")
			Session.set("filter_target", null)
			# 进入某个视图应该把上一个视图的过滤条件清空
			# 见issue：过滤器，在对象的某个yml文件定义的视图中设置过滤条件后，切换到另一个yml视图，刚设置的过滤条件应该清除掉 #1571
			Session.set("filter_items", null)

		if Session.get("object_name") != FlowRouter.getParam("object_name")
			Session.set("list_view_id", null)

		if queryParams?.hidden_header=="true"
			Session.set("hidden_header", true)

		app_id = FlowRouter.getParam("app_id")
		if (app_id != "-")
			Session.set("app_id", app_id)
		objectName = FlowRouter.getParam("object_name")
		Session.set("object_name", objectName)
		Session.set("list_view_id", FlowRouter.getParam("list_view_id"))
		Session.set("list_view_visible", false)

		Tracker.afterFlush ()->
			Session.set("list_view_visible", true)

		
		page = Steedos.Page.getPage('list',Session.get("app_id"), objectName);
		if page
			main = "page_object"
			regions = window._.defaultsDeep({display: Steedos.Page.getDisplay(objectName)}, FlowRouter.current().queryParams, {
				page: page,
				appId: Session.get("app_id"),
				objectName: objectName,
				listViewId: Session.get("list_view_id"),
				pageType: "list",
				__timestamp: new Date().getTime()
			});
		# console.log('/grid/:list_view_id regions===>', regions)	
		BlazeLayout.render Creator.getLayout(),
			main: main,
			regions: regions
