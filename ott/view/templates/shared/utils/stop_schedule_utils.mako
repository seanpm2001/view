## -*- coding: utf-8 -*-
##
## routines for stop / stop_schedule pages
##
<%namespace name="util" file="/shared/utils/misc_utils.mako"/>
<%namespace name="form" file="/shared/utils/form_utils.mako"/>
<%namespace name="su"   file="/shared/utils/stop_utils.mako"/>

<%def name="sort_val()">
<%
    sort_val = 'time' if 'sort' in request.params and request.params['sort'] == 'time' else 'destination'
    return sort_val
%>
</%def>


<%def name="sort_by_time()">
<%
    sort_by_time = True   if 'sort' in request.params and request.params['sort'] == 'time' else False
    return sort_by_time
%>
</%def>


<%def name="make_stop_schedule_url(stop, sort, extra_params, all=False)">
<%
    ## TODO: make the month/day/route variables more abstract, with better tests for None and '' values
    month  = '' if 'month' not in request.params else "&month={0}".format(request.params['month'])
    day    = '' if 'day'   not in request.params else "&day={0}".format(request.params['day'])
    route  = '' if all or 'route' not in request.params else "&route={0}".format(request.params['route'])
    url = "stop_schedule.html?stop_id={0}&sort={1}{2}{3}{4}{5}".format(stop['stop_id'], sort, route, month, day, extra_params)
    return url
%>
</%def>

##
## the crazy Today, 10/25, 10/26, more stuff from stop schedule pages
##
<%def name="svc_key_tabs(tabs, extra_params)">
    <ul id="contenttabs">
        %for t in tabs:
          %if 'url' in t:
            <li class="normal"><a href="${t['url']}&sort=${sort_val()}${extra_params}"><span>${t['name']}</span></a></li>
          %else:
            <li class="selected"><span>${t['name']}</span></li>
          %endif
        %endfor
    </ul>
    %if 'more' in request.params:
    <div id="moreform" class="group">
        <form name="select_date" id="select_date_id" method="GET" action="stop_schedule.html" class="triptools-form">
            ${form.get_extra_params_hidden_inputs()}
            <input type="hidden" name="stop_id" value="${stop['stop_id']}" />
            <input type="hidden" name="sort"    value="${sort_val()}" />
            %if more_form:
            ${util.month_select(more_form['month'])} ${util.day_select(more_form['day'])}
            <input name="submit" type="submit" value="${_(u'Select')}" class="submit" />
            %endif
        </form>
    </div>
    %endif
</%def>

##
## switch to show all routes if we're just showing a single route stop times...
##
<%def name="schedule_all_routes_link(stop, extra_params)">
<div class="contenttabs-bar group">
    <p class="singleroute">
    %if 'single_route_name' in stop and stop['single_route_name'] != None:
    <b>${_(u'Showing only')} ${stop['single_route_name']}</b>
     &nbsp;|&nbsp; <a href="${make_stop_schedule_url(stop, sort_val(), extra_params, True)}">${_(u'Show all lines')}</a>
    %endif
    </p>
</%def>

##
## sort schedule by either route (blocky view) or time (list view)
##
<%def name="schedule_sort_by_links(stop, extra_params)">
    <p class="sort">
        <b>${_(u'Sort')}:</b>
        ${util.link_or_strong(_(u'By destination'), not sort_by_time(), make_stop_schedule_url(stop, 'destination', extra_params), _('sort'))}
         &nbsp;|&nbsp;
        ${util.link_or_strong(_(u'By time'), sort_by_time(), make_stop_schedule_url(stop, 'time', extra_params), _('sort'))}
    </p>
</div><!-- end .contenttabs-bar -->
</%def>

##
## sort schedule by either route (blocky view) or time (list view)
##
<%def name="schedule_render(ss, pretty_date, extra_params, is_mobile=False)">
    <%
        from ott.view.utils import agency_template
        url = agency_template.make_url_template()
    %>
    %if sort_by_time():
    <p>
    %%
    %% SHOW schedule as a list, with headsign to left of time...
    %%
    %for s in ss['stoptimes']:
    <% 
        id = s['h']
        hs = ss['headsigns'][id]
    %> 
    <b>${s['t']}</b> ${hs['route_name']} ${_(u'to')} ${hs['headsign']}<br/>
    %endfor
    </p>
    %%
    %% SHOW schedule grouped under headsign
    %%
    %else:
    %for h in ss['headsigns'].keys():
    <% 
        hs = ss['headsigns'][h]
    %>
    <h3 class="tight">
        ${hs['route_name']} ${_(u'to')} ${hs['headsign']}
    </h3>
    <p class="tight">
        %for s in ss['stoptimes']:
            %if s['h'] == h:
            ${s['t']}&nbsp; 
            %endif
        %endfor
    </p>
    <p>
        <a href="${url.get_arrivals_url(stop_id=hs['stop_id'], route_id=hs['route_id'], device=is_mobile)}">${_(u'Next arrivals')}</a>
    </p>
    %endfor
    %endif
</%def>

        %if hs['has_alert']:
        ${util.alerts_inline_icon_link()}
        %endif

