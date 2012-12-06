# -*- coding: utf-8 -*- 
<%inherit file="layout.mako"/>

<!-- mako question: how can an inherited stylesheet add to the header section ??? -->
<link rel="stylesheet" href="/css/stop.css">


<h1>${_(u"Stop Details")}</h1>

<h5>${_(u"Stop ID")}: ${request.params['stop_id']}</h5>
%if stop_name:
<h5>Name: ${stop_name}</h5>
%if shelter:
<h6>NOTE: good news, there is a shelter at this stop!</h6>
%endif
%endif
%if latlon:
<iframe width='350px' height='250px' frameborder='0' scrolling='no' marginheight='0' marginwidth='0' 
  src='http://maps.google.com/maps?output=svembed&layer=c&cbp=13,,,,&cbll=${latlon}&ll=${latlon}&z=17'>
</iframe>
%endif
<p>
<a href="${request.route_url('form')}">New Search</a>
</p>


<%include file="vote.mako" args="stop_id=request.params['stop_id'], user_id=-111"/>
