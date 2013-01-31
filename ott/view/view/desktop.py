from pyramid.view import view_config
import utils


@view_config(route_name='stop_desktop', renderer='desktop/stop.html')
def stop(request):
    '''
       what do i do?
       1. ...
       2. ...
    '''
    alerts = None
    stop = request.model.get_stop()
    if stop and 'routes' in stop:
        routes = stop['routes']
        alerts = request.model.get_alerts(routes)

    ret_val = {}
    ret_val['stop'] = stop
    ret_val['stop']['alerts'] = alerts

    return ret_val


@view_config(route_name='stop_schedule_desktop', renderer='desktop/stop_schedule.html')
def stop_schedule(request):
    '''
       what do i do?
       1. ...
       2. ...
    '''
    date  = utils.get_first_param_as_date(request)
    more  = utils.get_first_param(request, 'more')
    route = utils.get_first_param(request, 'route')
    has_route = utils.is_valid_route(route)

    ret_val = {}
    ret_val['more_form']   = utils.get_day_info(date)
    ret_val['pretty_date'] = utils.pretty_date(date)
    ret_val['tabs'] = utils.get_svc_date_tabs(date, '/stop_schedule.html?route={0}'.format(route), more is None) 
    if has_route:
        ret_val['stop'] = request.model.get_stop_schedule_single(route)
    else:
        ret_val['stop'] = request.model.get_stop_schedule_multiple(route)

    ret_val['stop']['alerts'] = request.model.get_alerts(route)

    return ret_val


@view_config(route_name='stop_geocode_desktop', renderer='desktop/stop_geocode.html')
def stop_geocode(request):
    '''
       what do i do?
       1. ...
       2. ...
    '''
    ret_val = {}
    ret_val['stop'] = request.model.get_stop()

    return ret_val


@view_config(route_name='route_stop_desktop', renderer='desktop/route_stop_list.html')
def route_stops_list(request):
    '''
       what do i do?
       1. ...
       2. ...
    '''
    ret_val = {}
    ret_val['route_stops'] = request.model.get_route_stops_list()

    return ret_val


@view_config(route_name='find_stop_desktop', renderer='desktop/find_stop.html')
def find_stop(request):
    '''
       what do i do?
       1. ...
       2. ...
    '''
    ret_val = {}
    ret_val['routes'] = request.model.get_routes()
    ret_val['place']  = {'name':'822 SE XXX Street', 'lat':'45.5', 'lon':'-122.5'}

    return ret_val


@view_config(route_name='feedback_desktop', renderer='desktop/feedback.html')
def feedback(request):
    '''
       what do i do?
       1. ...
       2. ...
    '''
    ret_val = {}
    ret_val['stop'] = request.model.get_stop()

    return ret_val


@view_config(route_name='tracker_desktop', renderer='desktop/tracker.html')
def tracker(request):
    '''
       what do i do?
       1. ...
       2. ...
    '''
    ret_val = {}
    ret_val['routes'] = request.model.get_routes()['routes']

    return ret_val
