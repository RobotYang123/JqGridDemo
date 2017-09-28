<!-- 
	author: RobotYang
	update: 20170928-1220
	github: https://github.com/RobotYang123
 -->
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}"></c:set>

<link rel="stylesheet" href="${contextPath}/static/assets/css/jquery-ui.css" />
<link rel="stylesheet" href="${contextPath}/static/assets/css/datepicker.css" />
<link rel="stylesheet" href="${contextPath}/static/assets/css/ui.jqgrid.css" />
<link rel="stylesheet" href="${contextPath}/static/assets/css/jquery.gritter.css" />

<div class="row">
	<div class="col-sm-12">
		<!-- #section:elements.tab -->
		<div class="tabbable">

			<ul class="nav nav-tabs" id="myTab">
				<li class="active">
					<a data-toggle="tab" href="#tp-userlist">
						<i class="green ace-icon fa fa-home bigger-120"></i> 账户总览
					</a>
				</li>
			</ul>
			
			<div class="tab-content">
				<!-- 账户总览 -->
				<div id="tp-userlist" class="tab-pane fade in active">
					<div class="form-group">
						<table id="grid-table"></table>
						<div id="grid-pager"></div>
					</div>
				</div>					
			</div>
			<!-- /.tab-content -->
		</div>
		<!-- /.tabbable -->
	</div>
	
</div>
<!-- /.row -->


<!-- page specific plugin scripts -->
<script type="text/javascript">
	var scripts = [ null, 
		"${contextPath}/static/assets/js/date-time/bootstrap-datepicker.js",
		"${contextPath}/static/assets/js/jquery.gritter.js", 
		"${contextPath}/static/assets/js/date-time/locales/bootstrap-datepicker.zh-CN.js",
		"${contextPath}/static/assets/js/jqGrid/jquery.jqGrid.js", 
		"${contextPath}/static/assets/js/jqGrid/i18n/grid.locale-cn.js",
		"${contextPath}/static/assets/js/daterange/moment.js", 
		"${contextPath}/static/assets/js/daterange/moment-with-cn.js", 
		null
	];
</script>

<!-- 账户总览 -->
<script type="text/javascript">
	$('.page-content-area').ace_ajax('loadScripts', scripts, function() {
		// inline scripts related to this page
		jQuery(function($) {
			//初始化时间插件语言包
			moment.locale('zh-cn');
			
			/* 账户总览 begin  ------------------------------------------------------------------------------------- */
			var grid_selector = "#grid-table";
			var pager_selector = "#grid-pager";

			// resize to fit page size
			$(window).on('resize.jqGrid', function() {
				$(grid_selector).jqGrid('setGridWidth', $(".page-content").width());
			});
			
			// resize on sidebar collapse/expand
			var parent_column = $(grid_selector).closest('[class*="col-"]');
			$(document).on('settings.ace.jqGrid', function(ev, event_name, collapsed) {
				if (event_name === 'sidebar_collapsed' || event_name === 'main_container_fixed') {
					// setTimeout is for webkit only to give time for DOM changes and then redraw!!!
					setTimeout(function() {
						$(grid_selector).jqGrid('setGridWidth', parent_column.width());
					}, 0);
				}
			});

			//Seelink：http://blog.mn886.net/jqGrid/ ; http://mj4d.iteye.com/blog/1628851
			jQuery(grid_selector).jqGrid({
				subGrid : false,
				url : "${contextPath}/sys/sysuser/getSysUser",
				mtype : "post",
				datatype : "json",
				height : "50%",
				colModel : [
				{
					label: '操作',
					name : "operate", //该列设置的唯一名称
					index : "operate", //排序时所使用的索引名称
					width : 70, //该列的宽度
					fixed : true, //列宽是否固定不可变
					sortable : false, //该列是否可以排序
					search : false, //该列是否可以被列为搜索条件
					resizable : false, //是否可改变列大小
					exportable : false, //自定义参数：是否可以导出，默认true
					formatter : "actions", //格式化该列的方式，采用预设类型或自定义函数名。Seelink：http://blog.csdn.net/tarataotao/article/details/10495743
					formatoptions : { //用预设类型格式化该列时设置的选项，选项不同配置项不同
						keys : true,
						delbutton : <shiro:hasPermission name="${ROLE_KEY}:sysuser:delete">true</shiro:hasPermission><shiro:lacksPermission name="${ROLE_KEY}:sysuser:delete">false</shiro:lacksPermission>,
						delOptions : {
							recreateForm : true,
							beforeShowForm : beforeDeleteCallback
						},
						//editbutton是否显示行编辑按钮，当为fasel时,editformbutton也要设为false
						editbutton : <shiro:hasPermission name="${ROLE_KEY}:sysuser:edit">true</shiro:hasPermission><shiro:lacksPermission name="${ROLE_KEY}:sysuser:edit">false</shiro:lacksPermission>,
						//editformbutton : false, //编辑类型：false为显示内联编辑表单，true显示弹窗编辑表单
						editformbutton : false, //编辑类型：false为显示内联编辑表单，true显示弹窗编辑表单
						editOptions : {
							recreateForm : false,
							beforeShowForm : beforeEditCallback,
							closeOnEscape: true, //按Esc关闭弹窗编辑表单
							afterSubmit: function (response, postdata) { //弹窗编辑表单操作成功后的后续操作
								//if (response.status == 200) alert(456);
							},
						},
						onSuccess: function(response) { //行编辑操作成功后的后续操作							
							$(grid_selector).trigger("reloadGrid"); //刷新记录总览
							 //    location.reload();//页面刷新
						},
					},
				}, 
				{
					label: 'ID',
					name : 'id',
					index : 'id',
					width : 60,
					sorttype : "long",
					search : true,
					searchoptions : {sopt : ['eq']},
				}, 
				{
					label: 'PID',
					name : 'parent',
					index : 'parent',
					width : 60,
					sorttype : "long",
					search : true,
					searchoptions : {sopt : ['eq']},
				}, 
				{
					label: '用户名',
					name : 'userName',
					index : 'userName',
					width : 100,
					editable : true,
					editoptions : {size : "20", maxlength : "50"},
					search : true,
					searchoptions : {sopt : ['cn']},
					editrules : {required : true},
				}, 
				{
					label: '电话',
					name : 'phone',
					index : 'phone',
					width : 100,
					editable : true,
					editoptions : {maxlength : "11"},
					searchoptions : {sopt : ['eq']},
					editrules : {required : true},
				}, 
				{
					label: '角色名',
					name : 'roleCn',
					index : 'role',
					width : 100,
					editable : true,
					edittype : "select",
					editoptions : {
						dataUrl : "${contextPath}/sys/role/getRoleSelectList"
					},
					search : false,
				}, 
				{
					label: '积分',
					name : 'score',
					index : 'score',
					width : 100,
					sorttype : "long",
					search : false,
					editable : false,
				}, 
				{
					label: '提成',
					name : 'ticeng',
					index : 'ticeng',
					width : 100,
					sorttype : "long",
					search : false,
					editable : false,
				}, 
				{
					label: '性别',
					name : 'sexCn',
					index : 'sex',
					width : 80,
					editable : true,
					edittype : "select",
					editoptions : {value : "1:男;2:女"},
					search : false,
				}, 
				{
					label: '部门名称',
					name : 'departmentValue',
					index : 'departmentKey',
					width : 120,
					editable : true,
					edittype : "select",
					//editoptions : {value : "YFB:研发部;XZB:行政部"},
					editoptions : {
						dataUrl : "${contextPath}/sys/department/getDepartmentSelectList"
					},
					search : false,
				}, 
				{
					label: '禁用状态',
					name : 'statusCn',
					index : 'status',
					width : 80,
					editable : true,
					edittype : "checkbox",
					editoptions : {value : "是:否"},
					unformat : aceSwitch,
					search : false,
				}, 
				{
					label: '最后登入时间',
					name : 'lastLoginTime',
					index : 'lastLoginTime',
					width : 150,
					sorttype : "date",
					search : false,
				}
				],
				sortname : "id",
				sortorder : "desc",
				viewrecords : true, //定义是否要显示总记录数
				rowNum : 10,
				rowList : [ 10, 20, 30 ],
				pager : pager_selector,
				editurl : "${contextPath}/sys/sysuser/operateSysUser",
				//不是常用的一些参数
				//caption : "账户总览", //表格标题行
				//autowidth : true, //是否自动分配列宽
				altRows : true,
				multiselect : true, //是否显示多选框checkbox
				multiboxonly : true, //是否可以连选多个选框
				//multikey : "ctrlKey", //连选时需要按住ctrl键
				/**
				grouping : true, 
				groupingView : { 
					 groupField : ['name'],
					 groupDataSorted : true,
					 plusicon : 'fa fa-chevron-down bigger-110',
					 minusicon : 'fa fa-chevron-up bigger-110'
				},
				*/
				//数据和JqGrid加载完成后
				loadComplete : function(res) {
					var table = this;
					setTimeout(function(){
						styleCheckbox(table);
						updateActionIcons(table);
						updatePagerIcons(table);
						enableTooltips(table);
					}, 0);
				},
			});
			
			// enable search/filter toolbar
			// jQuery(grid_selector).jqGrid('filterToolbar',{defaultSearch:true,stringResult:true})
			// jQuery(grid_selector).filterToolbar({});
			// navButtons
			jQuery(grid_selector).jqGrid('navGrid', pager_selector, { // navbar options
				edit : true,
				editicon : 'ace-icon fa fa-pencil blue',
				add : true,
				addicon : 'ace-icon fa fa-plus-circle purple',
				del : true,
				delicon : 'ace-icon fa fa-trash-o red',
				search : true,
				searchicon : 'ace-icon fa fa-search orange',
				refresh : true,
				refreshicon : 'ace-icon fa fa-refresh blue',
				view : true,
				viewicon : 'ace-icon fa fa-search-plus grey'
			}, {
				// edit record form
				// closeAfterEdit: true,
				// width: 700,
				recreateForm : true,
				closeOnEscape: true, //按Esc关闭弹窗编辑表单
				closeAfterEdit: true,
				beforeShowForm : function(e) {
					var form = $(e[0]);
					form.closest('.ui-jqdialog').find('.ui-jqdialog-titlebar').wrapInner('<div class="widget-header" />');
					styleEditFormCustomer(form);					
					styleEditForm(form);
				},
				errorTextFormat: function (response) {
					var result = eval('('+response.responseText+')');					
					return result.message;
				}
			}, {
				// new record form
				// width: 700,
				recreateForm : true,
				closeAfterAdd : true,
				closeOnEscape: true, //按Esc关闭弹窗编辑表单
				viewPagerButtons : false,
				beforeShowForm : function(e) {
					var form = $(e[0]);
					form.closest('.ui-jqdialog').find('.ui-jqdialog-titlebar').wrapInner('<div class="widget-header" />');
					styleEditFormCustomer(form);
					styleEditForm(form);
				},
				errorTextFormat: function (response) {
					var result = eval('('+response.responseText+')');
					return result.message;
				}
			}, {
				// delete record form
				recreateForm : true,
				beforeShowForm : function(e) {
					var form = $(e[0]);
					if (form.data('styled'))
						return false;
					form.closest('.ui-jqdialog').find('.ui-jqdialog-titlebar').wrapInner('<div class="widget-header" />');
					styleDeleteForm(form);
					form.data('styled', true);
				},
				onClick : function(e) {
					// alert(1);
				}
			}, {
				// search form
				recreateForm : true,
				closeOnEscape: true, //按Esc关闭弹窗编辑表单
				afterShowSearch : function(e) {					
					var form = $(e[0]);
					form.closest('.ui-jqdialog').find('.ui-jqdialog-title').wrap('<div class="widget-header" />');
					styleSearchForm(form);
				},
				afterRedraw : function() {
					styleSearchFilters($(this));
				//	console.log(111+"filters");
				},
				multipleSearch : true 
				/**
				 * multipleGroup:true, showQuery: true
				 */
			}, {
				// view record form
				recreateForm : true,
				closeOnEscape: true,
				beforeShowForm : function(e) {
					var form = $(e[0]);
					form.closest('.ui-jqdialog').find('.ui-jqdialog-title').wrap('<div class="widget-header" />');
					styleEditFormCustomer(form);
					styleEditForm(form);
					console.log("my123");
				}
				
			});
			
			//添加自定义导出数据按钮 add custom button to export the data to excel
			var canExport = true;
			if(canExport){
				jQuery(grid_selector).jqGrid('navButtonAdd', pager_selector,{
					caption : "",	//按钮标题
					title : "导出Excel",	//按钮提示
					buttonicon : "ace-icon fa fa-file-excel-o green",
					onClickButton : function () {
						exportGridToExcel(grid_selector, "导出账户");
					},
				});
			}
			//导出按钮 end
			
			// var selr = jQuery(grid_selector).jqGrid('getGridParam','selrow');

			$(document).one('ajaxloadstart.page', function(e) {
				$(grid_selector).jqGrid('GridUnload');
				$('.ui-jqdialog').remove();
			});
			/* 账户总览 end ------------------------------------------------------------------------------------- */
			
	
			/* Customer Function begin ------------------------------------------------------------------------------------- */
			function styleEditFormCustomer(form) {
				// enable datepicker on "birthday" field and switches for "stock" field
				form.find('input[name=birthday]').val(123);
				form.find('input[name=birthday]').datepicker({
					language: 'zh-CN',
					format : 'yyyy-mm-dd',
					autoclose : true,
				});
				form.find('input[name=statusCn]').addClass('ace ace-switch ace-switch-5').after('<span class="lbl"></span>');
				// don't wrap inside a label element, the checkbox value won't be submitted (POST'ed)
				// .addClass('ace ace-switch ace-switch-5').wrap('<label class="inline" />').after('<span class="lbl"></span>');
			}
			/* Customer Function end ------------------------------------------------------------------------------------- */
				
			
			/* JqGrid Function begin ------------------------------------------------------------------------------------- */
			$(window).triggerHandler('resize.jqGrid');
				
			// inline scripts related to this page// switch element when editing inline
			function aceSwitch(cellvalue, options, cell) {
				setTimeout(function() {
					$(cell).find('input[type=checkbox]').addClass('ace ace-switch ace-switch-5').after('<span class="lbl"></span>');
				}, 0);
			}
			
			// enable datepicker
			function pickDate(cellvalue, options, cell) {
				setTimeout(function() {
					$(cell).find('input[type=text]').datepicker({
						format : 'yyyy-mm-dd',
						autoclose : true,
						language: 'zh-CN'
					});
				}, 0);
			}
			
			function styleEditForm(form) {
				console.log("ppp111");
				// update buttons classes
				var buttons = form.next().find('.EditButton .fm-button');
				buttons.addClass('btn btn-sm').find('[class*="-icon"]').hide();// ui-icon, s-icon
				buttons.eq(0).addClass('btn-primary').prepend('<i class="ace-icon fa fa-check"></i>');
				buttons.eq(1).prepend('<i class="ace-icon fa fa-times"></i>');
		
				buttons = form.next().find('.navButton a');
				buttons.find('.ui-icon').hide();
				buttons.eq(0).append('<i class="ace-icon fa fa-chevron-left"></i>');
				buttons.eq(1).append('<i class="ace-icon fa fa-chevron-right"></i>');
			 
			}
		
			function styleDeleteForm(form) {
				var buttons = form.next().find('.EditButton .fm-button');
				buttons.addClass('btn btn-sm btn-white btn-round').find('[class*="-icon"]').hide();// ui-icon, s-icon
				buttons.eq(0).addClass('btn-danger').prepend('<i class="ace-icon fa fa-trash-o"></i>');
				buttons.eq(1).addClass('btn-default').prepend('<i class="ace-icon fa fa-times"></i>');
			}
		
			function styleSearchFilters(form) {
				console.log(00);
				form.find('.delete-rule').val('X');
				form.find('.add-rule').addClass('btn btn-xs btn-primary');
				form.find('.add-group').addClass('btn btn-xs btn-success');
				form.find('.delete-group').addClass('btn btn-xs btn-danger');
			}
			
			function styleSearchForm(form) {
				console.log("search");
				var dialog = form.closest('.ui-jqdialog');
				var buttons = dialog.find('.EditTable');				
				buttons.find('.EditButton a[id*="_reset"]').addClass('btn btn-sm btn-info').find('.ui-icon').attr('class', 'ace-icon fa fa-retweet');
				buttons.find('.EditButton a[id*="_query"]').addClass('btn btn-sm btn-inverse').find('.ui-icon').attr('class', 'ace-icon fa fa-comment-o');
				buttons.find('.EditButton a[id*="_search"]').addClass('btn btn-sm btn-purple').find('.ui-icon').attr('class', 'ace-icon fa fa-search');
			}
		
			function beforeDeleteCallback(e) {
				var form = $(e[0]);
				if (form.data('styled'))
					return false;
				form.closest('.ui-jqdialog').find('.ui-jqdialog-titlebar').wrapInner('<div class="widget-header" />');
				styleDeleteForm(form);
				form. data('styled', true);
			}
		
			function beforeEditCallback(e) {
				var form = $(e[0]);
				form.closest('.ui-jqdialog').find('.ui-jqdialog-titlebar').wrapInner('<div class="widget-header" />');
				styleEditForm(form);
			}
		
			// it causes some flicker when reloading or navigating grid
			// it may be possible to have some custom formatter to do this as the grid is being created to prevent this
			// or go back to default browser checkbox styles for the grid
			function styleCheckbox(table) {
				/**
				 * $(table).find('input:checkbox').addClass('ace') .wrap('<label />') .after('<span class="lbl align-top" />') $('.ui-jqgrid-labels th[id*="_cb"]:first-child')
				 * .find('input.cbox[type=checkbox]').addClass('ace') .wrap('<label />').after('<span class="lbl align-top" />');
				 */
			}
		
			// unlike navButtons icons, action icons in rows seem to be hard-coded
			// you can change them like this in here if you want
			function updateActionIcons(table) {
				/**
				 * var replacement = { 'ui-ace-icon fa fa-pencil' : 'ace-icon fa fa-pencil blue', 'ui-ace-icon fa fa-trash-o' : 'ace-icon fa fa-trash-o red', 'ui-icon-disk' : 'ace-icon fa fa-check green', 'ui-icon-cancel' :
				 * 'ace-icon fa fa-times red' }; $(table).find('.ui-pg-div span.ui-icon').each(function(){ var icon = $(this); var $class = $.trim(icon.attr('class').replace('ui-icon', '')); if($class in replacement)
				 * icon.attr('class', 'ui-icon '+replacement[$class]); })
				 */
			}
		
			// replace icons with FontAwesome icons like above
			function updatePagerIcons(table) {
				var replacement = {
					'ui-icon-seek-first' : 'ace-icon fa fa-angle-double-left bigger-140',
					'ui-icon-seek-prev' : 'ace-icon fa fa-angle-left bigger-140',
					'ui-icon-seek-next' : 'ace-icon fa fa-angle-right bigger-140',
					'ui-icon-seek-end' : 'ace-icon fa fa-angle-double-right bigger-140'
				};
				$('.ui-pg-table:not(.navtable) > tbody > tr > .ui-pg-button > .ui-icon').each(function() {
					var icon = $(this);
					var $class = $.trim(icon.attr('class').replace('ui-icon', ''));
		
					if ($class in replacement)
						icon.attr('class', 'ui-icon ' + replacement[$class]);
				});
			}
		
			function enableTooltips(table) {
				$('.navtable .ui-pg-button').tooltip({
					container : 'body'
				});
				$(table).find('.ui-pg-div').tooltip({
					container : 'body'
				});
			}
        		
       		//导出JqGrid数据到excel
			function exportGridToExcel(grid_selector, file_name){
				var fileName = file_name + "-"+ new Date().toLocaleString();
				//console.log(fileName);
				
				var rowIdsArr = $(grid_selector).getDataIDs(); //所有行数据对应的IDs
				var colNamesArr = $(grid_selector).jqGrid('getGridParam','colNames'); //获取所有列名（含checkbox,operate）
				var colModelArr = $(grid_selector).jqGrid('getGridParam','colModel'); //获取所有列配置（含operate）
				
				var exColNamesObj = {}; //[{colName:colTitle},{}...]
				var exRowDatasArr = [];
				
				$.each(colModelArr, function(k1,v1){
					//console.log(k1+"："+v1.name+"："+v1.exportable);
					if(v1.exportable==false || v1.name=="cb"){
						return true; //continue
					} else {
						exColNamesObj[v1.name] = colNamesArr[k1];
					}
				});
				//console.log(exColNamesObj);
				
				$.each(rowIdsArr,function(k2,v2){
					var rowOneObj = $(grid_selector).getRowData(v2); //获取一行数据（不含checkbox,operate）
					//console.log(rowOneObj);
					var tempExRowObj = {};
					$.each(exColNamesObj, function(k3,v3){
						tempExRowObj[k3] = rowOneObj[k3];
					});
					exRowDatasArr.push(tempExRowObj);
				});
				exRowDatasArr.unshift(exColNamesObj); //拼接列名和数据
				console.log(exRowDatasArr);
				
				var exDatas = "";
				$.each(exRowDatasArr,function(k3,obj3){
					$.each(obj3,function(k4,v4){
						exDatas += v4 + "\t"; // output each Row as tab delimited
					});
					exDatas += "\n"; // end of line at the end
				});
				//console.log(exDatas);
				//exit();
				
				//var form = "<form name='csvexportform' action='${contextPath}/sys/sysuser/operateSysUser?oper=excel' method='post'>";
				var form = "<form name='csvexportform' id='exportForm' class='hidden' action='${contextPath}/sys/attachment/exporOutput' method='post'>";
				form = form + "<input type='hidden' name='fileType' value='xls'>";
				form = form + "<input type='hidden' name='fileName' value='"+ fileName +"'>";
				form = form + "<input type='hidden' name='csvBuffer' value='" + encodeURIComponent(exDatas) + "'>";
				//form = form + "</form><script>document.csvexportform.submit();</sc"+"ript>";
				$("body").append(form); //追加导出表单
				$("#exportForm").submit(); //触发提交，导出数据
				$("#exportForm").remove(); //移除已导出的表单
				/* 
				//旧的导出方式：在新窗口启动导出事件
				OpenWindow = window.open('','','width=200,height=100');
				OpenWindow.document.write(form);
				OpenWindow.document.close();
				 */
			}
			
			
		/* JqGrid Function end ------------------------------------------------------------------------------------- */

			
		});
		//jQuery(function($) end
	});
	//loadScripts end
</script>

