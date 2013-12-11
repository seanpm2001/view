## -*- coding: utf-8 -*-
##
## planner lib
##
<%namespace name="util"  file="/shared/utils/misc_utils.mako"/>

##
## typical itinerary page title
##
<%def name="itin_page_title(plan)">TriMet: ${_(u'Trip Planner')} - ${_(u'From')} ${plan['from']['name']} ${_(u'to')} ${plan['to']['name']}</%def>
<%def name="str_title(plan)"><% return "{0} - {1} {2} {3}".format(_(u'Trip Planner'), plan['from']['name'], _(u'to'), plan['to']['name'])%></%def>
<%def name="str_description(plan)">
<% 
    title = arr = tm = dt = mode = opt = walk = ''
    try:
        title = str_title(plan)
        arr   = get_depart_arrive(plan['params']['is_arrive_by'])
        mode  = plan['params']['modes']
        opt   = get_optimize(plan['params']['optimize'])
        walk  = plan['params']['walk']

        itinerary = get_itinerary(plan)
        dt    = itinerary['date_info']['pretty_date']
        tm    = get_time(itinerary, plan['params']['is_arrive_by'])
    except Exception, e:
        print e

    return "{0}<br/>{1} {2}, {3}<br/>{4} {5} <br/>{6}<br/>{7} {8}".format(title, arr, tm, dt,  _(u'using'), mode, opt, _(u'with a maximum walk of'), walk)
%>
</%def>

##
## header details w/ from & to details, plus optional trip details & edit links
##
<%def name="render_trip_details(plan, itinerary=None, extra_params='')">
    <div id="details" class="group">
        <p class="origin"><img src="${util.img_url()}/start-end.png" width="0" height="1" /><strong>${_(u'From')}</strong> ${plan['from']['name']}</p>
        <p class="destination"><img src="${util.img_url()}/start-end.png" width="0" height="1" /><strong>${_(u'To')}</strong> ${plan['to']['name']}</p>
        %if itinerary:
        <p class="tripinfo">${get_depart_arrive(plan['params']['is_arrive_by'])} ${get_time(itinerary, plan['params']['is_arrive_by'])} ${itinerary['date_info']['pretty_date']}, ${_(u'using')} ${plan['params']['modes']} <a href="planner_form.html?${plan['params']['edit_trip']}${extra_params}" onclick="_gaq.push(['_trackEvent', 'TripPlanner', 'ClickTo', 'Itinerary edit top']);" class="hide">${_(u'Edit')}</a></p>
        <p class="tripinfo">${get_optimize(plan['params']['optimize'])} ${_(u'with a maximum walk of')} ${plan['params']['walk']} <a href="planner_form.html?${plan['params']['edit_trip']}${extra_params}" onclick="_gaq.push(['_trackEvent', 'TripPlanner', 'ClickTo', 'Itinerary edit top']);" class="hide">${_(u'Edit')}</a></p>
        %endif
    </div><!-- end #details -->
</%def>

##
## option tabs
##
<%def name="render_tabs(plan, extra_params)">
%if len(plan['itineraries']) > 1:
    <ol id="plannertabs" class="group">
        ${itin_tab(plan['itineraries'], 0, _(u'Your best bet'), extra_params)}
        ${itin_tab(plan['itineraries'], 1, _(u'Option 2'), extra_params)}
        ${itin_tab(plan['itineraries'], 2, _(u'Option 3'), extra_params)}
    </ol><!-- end #tabs -->
    <div class="plannertabs-underline"></div>
%endif
</%def>

##
## main part of the renderer
## (loop over the legs, and render them
##
<%def name="render_itinerary(itinerary, extra_params, is_mobile=False, no_expand=False)">
    <ol id="itinerary" class="transit">
        ##
        ## loop through the legs between start and end elements
        ## ${render_leg(leg, n)}
        %for n, leg in enumerate(itinerary['legs']):
            ${_render_leg(itinerary, n, is_mobile, extra_params, no_expand)}
        %endfor
    </ol><!-- end #itinerary -->
</%def>

##
## bottom console buttons for email, feedback, print, etc...
##
<%def name="render_console(plan, extra_params)">
    <div id="console" class="group hide">
        <p class="console-left">
            <a href="${util.mailto_url(str_title(plan))}" class="console-emailtext" onClick="_gaq.push(['_trackEvent', 'TripPlanner', 'ClickTo', 'Itinerary email-text']);"><span>${_(u'Email/Text')}</span></a>
            <a href="javascript:window.print();" class="console-print" onClick="_gaq.push(['_trackEvent', 'TripPlanner', 'PrintClickTo', 'Itinerary print']);"><span>${_(u'Print')}</span></a>
            <a href="m/${request.url}" class="console-mobile" onClick="_gaq.push(['_trackEvent', 'TripPlanner', 'ClickTo', 'Itinerary view on mobile']);"><span>${_(u'View on mobile')}</span></a>
        </p>
        <p class="console-right">
            <a href="planner_form.html?${plan['params']['return_trip']}${extra_params}" class="console-returntrip" onClick="_gaq.push(['_trackEvent', 'TripPlanner', 'ClickTo', 'Itinerary reverse']);"><span>${_(u'Return trip')}</span></a>
            <a href="planner_form.html?${plan['params']['edit_trip']}${extra_params}" class="console-edit" onClick="_gaq.push(['_trackEvent', 'TripPlanner', 'ClickTo', 'Itinerary edit']);"><span>${_(u'Edit/Start over')}</span></a>
        </p>
    </div><!-- end #console -->
</%def>

##
##
##
<%def name="render_alerts(itinerary)">
    %if itinerary['has_alerts']:
    <div id="alerts" class="group">
        %for alert in itinerary['alerts']:
        <p><img src="${util.img_url()}/alert.png" />
            <span class="alert-text">${alert['text']}</span>
            <span class="alert-time">${_(u'As of')} ${alert['start_date_pretty']} <a href="${alert['url']}" target="#">${_(u'(more...)')}</a></span>
        </p>
        %endfor
    </div><!-- end #alerts -->
    %endif
</%def>

<%def name="render_fares(itinerary, fares_url)">
<p class="fare">${_(u'Fare for this trip')}: <a href="${fares_url}">${_(u'Adult')}: ${itinerary['fare']['adult']}, ${_(u'Youth')}: ${itinerary['fare']['youth']}, ${_(u'Honored Citizen')}: ${itinerary['fare']['honored']}</a></p>
</%def>

<%def name="pretty_distance(dist)">
<%
    try:
        return str(dist['distance']) + " " + _(dist['measure'])
    except:
        return dist
%>
</%def>

<%def name="get_mode_img(mode)">
<%
    ''' return 20x20px mode gif for leg list 
    '''
    ret_val = ''
    path = util.planner_img_url()
    if mode == util.attr.BUS:
        ret_val = path + "/bus.png"
    if mode == util.attr.BICYCLE:
        ret_val = path + "/bicycle.png"
    if mode == util.attr.WALK:
        ret_val =  path + "/walk.png"
    if mode == util.attr.RAIL:
        ret_val = path + "/rail.png"
    if mode == util.attr.TRAM:
        ret_val = path + "/tram.png"
    if mode == util.attr.GONDOLA:
        ret_val = path + "/gondola.png"

    return ret_val
%>
</%def>

<%def name="get_mode_css_class(mode)">
<%
    ''' return css class names
    '''
    ret_val = ''
    if mode == util.attr.BUS:
        ret_val = 'step-bus-icon'
    if mode == util.attr.CAR:
        ret_val = 'step-car-icon'
    if mode == util.attr.BICYCLE:
        ret_val = 'step-bike-icon'
    if mode == util.attr.WALK:
        ret_val = 'step-walk-icon'
    if mode == util.attr.RAIL:
        ret_val = 'step-wes-icon'
    if mode == util.attr.TRAM:
        ret_val = 'step-max-icon'
    if mode == util.attr.GONDOLA:
        ret_val = 'step-aerialtram-icon'

    return ret_val
%>
</%def>

##
##
##
<%def name="itin_tab(itin_list, i, text, extra_params='')">
    %if len(itin_list) > i:
        <%
            it  = itin_list[i]
            sel = it['selected']
            n   = it['transfers']
            dur = it['date_info']['duration_min']
            tfer = _('${number} transfer', '${number} transfers', mapping={'number':n})
            fare = it['fare']['adult']
            url  = it['url']
        %>
        <!-- ${_('transfer')} or ${_('transfers')} -->
        %if sel:
        <li class="selected"><span class="selectedpadding"><b>${text}</b><br />${dur} ${_('mins')}, <span class="nobreak">${tfer},</span> ${fare}</span></li>
        %else:
        <li class="normal"><a href="${url}${extra_params}"><span><b>${text}</b><br/>${dur} ${_('mins')}, <span class="nobreak">${tfer},</span> ${fare}</span></a></li>
        %endif
    %endif
</%def>

##
##
##
<%def name="get_optimize(optimize)">
<%
    if optimize == 'SAFE':
        ret_val = _(u'Safest trip')
    elif optimize == 'TRANSFERS':
        ret_val = _(u'Fewest transfers')
    else:
        ret_val = _(u'Quickest trip')
    return ret_val
%>
</%def>

##
## footer of the trip planner form
## a img bar for the imap, with link to the map
##
<%def name="bottom_imap_bar()">
    <div id="imap-wrap">
        <section id="imap" class="group">
            <h3><a href="${util.url_domain()}/maptripplanner/index.htm"><strong>${_(u'Interactive Map Trip Planner')}</strong>: ${_(u'Get transit + biking directions in one itinerary')} &raquo;</a></h3>
        </section><!-- end #imap -->
    </div><!-- end #promobar-wrap -->
</%def>

##
## footer with the trip plan disclaimer
##
<%def name="bottom_disclaimer()">
    <div id="disclaimer">
        <p>${_(u'Times shown are estimates based on schedules and can be affected by traffic, road conditions, detours and other factors. Before you go, check')}
            <a href="/transittracker/about.htm" onClick="_gaq.push(['_trackEvent', 'Trip Planner Ads','ClickTo', '/transittracker/about.htm']);">TransitTracker</a>&trade;
            ${_(u'for real-time arrival information and any Service Alerts that may affect your trip: Call 503-238-RIDE (7433), visit m.trimet.org, or text your Stop ID to 27299.')}
        </p>
    </div>
</%def>


<%def name="get_time(itinerary, is_arrive_by)">
<%
    if is_arrive_by:
        time = itinerary['date_info']['end_time']
    else:
        time = itinerary['date_info']['start_time']
    return time
%>
</%def>

<%def name="get_itinerary(plan)">
<%
    # find target itinerary 
    for itin in plan['itineraries']:
        itinerary = itin
        if itin['selected']:
            break
    return itinerary
%>
</%def>

<%def name="get_depart_arrive(is_arrive=False)">
<%
    if is_arrive:
        ret_val = _(u'Arrive by')
    else:
        ret_val = _(u'Depart after') 
    return ret_val
%>
</%def>


<%def name="get_route_name(route)"><% return route['name'] + " " + _(u'to') + " " + route['headsign'] if route['headsign'] else ''%></%def>
<%def name="get_route_link(name, url, mode)">
<a href="${url}" title="${_(u'Show map and schedules for this route.')}" class="step-mode"><img src="${util.img_url()}/modes.png" width="0" height="1" class="${get_mode_css_class(mode)}" />${name}</a></%def>
<%def name="get_interline_note(interline)">
%if interline != None:
${_(u'which continues as ')} ${interline} (${_(u'stay on board')})
%endif
</%def>

<%def name="render_elevation(elevation, no_expand=False)">
            %if elevation != None:
                <p class="elevation"><span>
                    ${_(u'Total elevation uphill')}: ${_(u'${number} foot', u'${number} feet', mapping={'number':elevation['rise_ft']})}<br />
                    ${_(u'Total elevation downhill')}: ${_(u'${number} foot', u'${number} feet', mapping={'number':elevation['fall_ft']})}<br />
                    ${_(u'Steepest grade')}: ${elevation['grade']}<br />
                    %if elevation['points'] and len(elevation['points']) > 2:
                    <a href="#">${_(u'Elevation chart')}</a> ${util.dynamic_img("sparkline?points=" + elevation['points'], 100, 20, no_expand=no_expand)}</span>
                    %endif
                </p>
            %endif
</%def>

<%def name="render_start_end_maps(from_img_url, to_img_url, no_expand=False)">
        <div class="maps">
             <p class="walk-start">${_(u'Start')}<br />${util.dynamic_img(from_img_url, 300, 288, _(u'Map of starting point (300x288)'), no_expand=no_expand)}</p>
             <p class="walk-end">${_(u'End')}<br/>${util.dynamic_img(to_img_url, 300, 288, _(u'Map of ending point (300x288)'), no_expand=no_expand)}</p>
        </div><!-- end maps -->
</%def>

## They want 2-stage walk instructions, as per mock up...
## https://github.com/OpenTransitTools/view/blob/a5e80acff83277e593fb09b760ce94cf7311b454/ott/view/templates/desktop/planner.html
## Walk 0.36 mile west on SE Water Ave., Turn left on SE Madison St., Walk a short distance west on SE Madison St.
<%def name="render_steps(verb, frm, to, steps)">
                <ol>
                    %for i, s in enumerate(steps):
                    <%
                        name = s['name']
                        conjunction = _(u'on')
                        if name == '' and i == 0:
                            name = frm
                            conjunction = _(u'from')
                        elif name == '' and i+1 == len(steps):
                            name = to
                            conjunction = _(u'to')

                        instruct_verb = verb
                        turn = None
                        dir = s['relative_direction']
                        if dir != None:
                            dir = dir.lower().replace('_', ' ').strip()
                            #print dir, _(dir), _(unicode(dir)), _('right'), _(u'right'), _('left'), _('slightly left')
                            if dir not in ('continue'):
                                turn = _(u'Turn') + " " + _(dir) + " " + _(u'on') + " " + _(name)
                            else:
                                instruct_verb = dir.title()

                        instruct = _(instruct_verb) + " " + pretty_distance(s['distance']) + " " + _(s['compass_direction']) + " " + conjunction + " " + _(name)
                    %>
                    %if turn != None:
                    <li>${turn}</li>
                    %endif
                    <li>${instruct}</li>
                    %endfor
                </ol>
</%def>

<%def name="render_bicycle_leg(leg, i, extra_params='', no_expand=False)">
    <li class="num${i}">
        <div class="step-number"><img src="${util.img_url()}/numbers.png" width="0" height="1" /></div>
        <p>
            <%
                dir = leg['compass_direction'] if leg['compass_direction'] else ''
                bike_title = _(u'Bike') + " " + _(dir) + " " + pretty_distance(leg['distance'])
            %>
            ${bike_title} ${_(u'to')}
            %if leg['to']['stop']:
            <a href="${leg['to']['stop']['info']}${extra_params}" title="${_(u'Click for more information about this stop')}">${leg['to']['name']}</a>
            %else:
            ${leg['to']['name']}
            %endif

            %if leg['to']['stop']:
            <span class="stopid">${_(u'Stop ID')}&nbsp;${leg['to']['stop']['id']}</span>
            %endif
        </p>

        <div class="normal"><!-- hidden walking directions and map -->
            <a href="#leg_${i}" onClick="expandMe(this);" title="${_(u'Biking directions')}" class="open"><span class="open-text">${_(u'Expand')}</span><span class="close-text">${_(u'Close')}</span></a>
            <div class="description">
                ${render_elevation(leg['elevation'])}
                ${render_steps(_(u'Bike'), leg['from']['name'], leg['to']['name'], leg['steps'])}
                ${render_start_end_maps(leg['from']['map_img'], leg['to']['map_img'], no_expand=no_expand)}
                    <!--
                    TODO TODO TODO
                    1. generic 'direction' element in json
                    2. enum for different walk insturctions Straight/Left/Slight Left/etc...
                    3. Reformat entire Leg, ala what happens on old trip planner...
                       http://maps5.trimet.org/maps/print/V1/tripplanner?fromPlace=pdx&toPlace=zoo&time=6:45%20pm
                    4. Dynamic Load Images... 
                    TODO TODO TODO
                    -->
            </div><!-- end .description -->
        </div><!-- end .normal/hidden walking directions -->
    </li>
</%def>

<%def name="render_walk_leg(leg, i, extra_params='', no_expand=False)">
    <li class="num${i}">
        <div class="step-number"><img src="${util.img_url()}/numbers.png" width="0" height="1" /></div>
        <p>
            <% 
                dir = leg['compass_direction'] if leg['compass_direction'] else ''
                walk_title = _(u'Walk') + " " + _(dir) + " " + pretty_distance(leg['distance'])
            %>
            %if leg['steps']:
            ${walk_title} ${_(u'to')}
            %elif leg['to']['stop'] and leg['transfer']:
            ${_(u'Go to')}
            %else:
            ${walk_title} ${_(u'to')}
            %endif
            %if leg['to']['stop']:
            <a href="${leg['to']['stop']['info']}${extra_params}" title="${_(u'Click for more information about this stop')}">${leg['to']['name']}</a>
            %else:
            ${leg['to']['name']}
            %endif
            %if leg['to']['stop']:
            <span class="stopid">${_(u'Stop ID')}&nbsp;${leg['to']['stop']['id']}</span>
            %endif
        </p>

        <div class="normal"><!-- hidden walking directions and map -->
            %if no_expand:
            <div class="description">
            %else:
            <a href="#leg_${i}" onClick="expandMe(this);" title="${_(u'Walking directions')}" class="open"><span class="open-text">${_(u'Expand')}</span><span class="close-text">${_(u'Close')}</span></a>
            <div class="description">
            %endif
            %if leg['steps']:
                ${render_elevation(leg['elevation'], no_expand=no_expand)}
                ${render_steps(_(u'Walk'), leg['from']['name'], leg['to']['name'], leg['steps'])}
                ${render_start_end_maps(leg['from']['map_img'], leg['to']['map_img'], no_expand=no_expand)}
            %endif
            </div><!-- end .description -->
        </div><!-- end .normal/hidden walking directions -->
    </li>
</%def>

<%def name="is_interline(leg_list, n)">
<%
    ret_val = False
    try:
        if leg_list[n]['interline']:
            ret_val = True
    except:
        pass
    return ret_val
%>
</%def>

<%def name="render_transit_leg(leg_list, n, i, j, is_mobile, extra_params='')">
    <li class="num${i}">
        <div class="step-number"><img src="${util.img_url()}/numbers.png" width="0" height="1" /></div>
        <p>
            <%
                leg = leg_list[n] 

                route_name = get_route_name(leg['route'])
                route_mode = leg['mode']

                from_sched = leg['from']['stop']['schedule']
                from_name  = leg['from']['name']
                from_stop  = leg['from']['stop']['id']
                start_time = leg['date_info']['start_time']

                # with interline trips, we use the next leg for the arrival time / stop / etc...
                # (interline leg itself will be skipped ... see logic in render_leg(), which 'pass'es on interlines )
                interline = None
                if is_interline(leg_list, n+1):
                    leg = leg_list[n+1]
                    interline = leg['route']['name']

                to_sched   = leg['to']['stop']['schedule']
                to_name    = leg['to']['name']
                to_stop    = leg['to']['stop']['id']
                end_time   = leg['date_info']['end_time']

                if is_mobile:
                    route_url = leg['route']['schedulemap_url']
                else:
                    route_url = leg['route']['url']
            %>
            <a href="${from_sched}${extra_params}" title="${_(u'Show schedule for')} ${from_name}" class="step-time"><span>${start_time}</span></a> ${_(u'Board')} ${get_route_link(route_name, route_url, route_mode)}${get_interline_note(interline)}
            %if leg['alerts']:
            <a href="#alerts" title="${_(u'There is an alert that applies to this transit leg.  See the "alerts" section below for details')}" class="step-alert"><img src="${util.img_url()}/alert.png" /></a>
            %endif
        </p>
    </li>

    <li class="num${j}">
        <div class="step-number"><img src="${util.img_url()}/numbers.png" width="0" height="1" /></div>
        <p><a href="${to_sched}${extra_params}" title="${_(u'Show schedule for')} ${to_name}" class="step-time"><span>${end_time}</span></a> ${_(u'Get off at')} <a href="${leg['to']['stop']['info']}${extra_params}" title="${_(u'More information about this stop')}">${to_name}</a> <span class="stopid">${_(u'Stop ID')}&nbsp;${to_stop}</span></p>
    </li>
</%def>

<% leg_id = 1 %>
<%def name="_render_leg(itinerary, n, is_mobile, extra_params, no_expand)">
<%
    ''' call render stuff above...
    '''
    ret_val = ''

    global leg_id
    if n == 0:
        leg_id = 1

    leg_list = itinerary['legs']
    leg = leg_list[n]

    if is_interline(leg_list, n):
        pass   # ignore interline legs (assume they're interline transit legs, which are handled below)
    elif leg['mode'] in (util.attr.BUS, util.attr.TRAM, util.attr.RAIL, util.attr.TRAIN, util.attr.GONDOLA):
        ret_val = render_transit_leg(leg_list, n, leg_id, leg_id+1, is_mobile, extra_params)
        leg_id = leg_id + 2 
    elif leg['mode'] == util.attr.WALK:
        ret_val = render_walk_leg(leg, leg_id, extra_params, no_expand)
        leg_id = leg_id + 1 
    elif leg['mode'] == util.attr.BICYCLE:
        ret_val = render_bicycle_leg(leg, leg_id, extra_params)
        leg_id = leg_id + 1

    return ret_val
%>
</%def>