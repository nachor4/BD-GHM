	function json2html(json) {
		var i, ret = document.createElement('ul'), li;
		for( i in json) {
			li = ret.appendChild(document.createElement('li'));
			li.appendChild(document.createTextNode(i+": "));
			if( typeof json[i] === "object") li.appendChild(json2html(json[i]));
			else li.firstChild.nodeValue += json[i];
		}
		return ret;
	}			
	
	function loadSelect(url,select,msgErr){
		$.ajax({
			url: url,
			type: "GET",
			dataType: 'json',
			success: function(json) {
				$(json).each(function(i,obj){
					$(select).append('<option value="'+obj.id+'">'+obj.nombre+'</option>');
				});
			},
			error: function(e) {
			   alert(msgErr);
			}
		});				
	}
	
	var formCallBacks ={
		'tabs-addHouse': function(){
			$("#tabs-deleteInmueble form select[name=inmueble]").html('<option value="">Seleccione una opción</option>');
			loadSelect(
				"/api/inmueble.php",
				"#tabs-deleteInmueble form select[name=inmueble]",
				"Ups... no se pudieron cargar los Inmuebles de 'Eliminar Inmueble'"
			);			
		}
	};
	
	formCallBacks['tabs-addApartment'] = formCallBacks['tabs-addHouse'];
	formCallBacks['tabs-deleteInmueble'] = formCallBacks['tabs-addHouse'];
	
	
	$(document).ready(function () {
		$('h1').addClass('ui-widget ui-widget-header ui-accordion-header ui-helper-reset ui-state-default ui-corner-all ui-helper-clearfix');
		$('#tabs').tabs().addClass( "ui-tabs-vertical ui-helper-clearfix" );
		$('#tabs .ui-tabs-nav ').tabs().addClass( "ui-corner-tl ui-corner-bl" );
		$('#tabs .ui-tabs-nav').tabs().removeClass( "ui-corner-all" );
		$( "#tabs li" ).removeClass( "ui-corner-top" ).addClass( "ui-corner-left" );
		
		$("form input[type=submit]").button();
		$("form input[type=text]").addClass('ui-widget ui-corner-all');
		
		//Cargo las categorías de las casas
		loadSelect(
			"/api/house_cat.php",
			"#tabs-addHouse form select[name=categoria]",
			"Ups... no se pudieron cargar las Categorias de 'Agregar Casa'"
		);
		
		//Cargo el Listado de Anuncios
		loadSelect(
			"/api/anuncios.php",
			"#tabs-getConsulta form select[name=anuncio]",
			"Ups... no se pudieron cargar los Anuncios de 'Consultar Consultas'"
		);		
		
		//Cargo el Listado de Inmuebles
		loadSelect(
			"/api/inmueble.php",
			"#tabs-deleteInmueble form select[name=inmueble]",
			"Ups... no se pudieron cargar los Inmuebles de 'Eliminar Inmueble'"
		);		
	
		$("form").submit(function(e){
			e.preventDefault();
			var form = $(e.currentTarget)
			
			$("input, select",form).attr("readonly","readonly");
			$("input[type=submit]",form).button("disable");
			
			$.ajax({
				url: "/api/"+form.attr("action"),
				type: form.attr("method").toUpperCase(),
				data: form.serialize(),
				dataType: 'json',
				complete: function(){
					$("input, select",form).removeAttr("readonly");
					$("input[type=submit]",form).button("enable");				
					
					formWrap = form.parent().attr('id')
					if ($.isFunction(formCallBacks[formWrap])) formCallBacks[formWrap]();
				},
				success: function(json) {
				   $('.resoult',form.parent()).html(json2html(json));
				},
				error: function(e) {
				   console.log(e.message);
				}
			});			
			
			$(form)[0].reset();
			
		}); //--form submit
		
	});

