##
# Wait until the test condition is true or a timeout occurs. Useful for waiting
# on a server response or for a ui change (fadeIn, etc.) to occur.
#
# @param testFx javascript condition that evaluates to a boolean,
# it can be passed in as a string (e.g.: "1 == 1" or "$('#bar').is(':visible')" or
# as a callback function.
# @param onReady what to do when testFx condition is fulfilled,
# it can be passed in as a string (e.g.: "1 == 1" or "$('#bar').is(':visible')" or
# as a callback function.
# @param timeOutMillis the max amount of time to wait. If not specified, 3 sec is used.
##
waitFor = (testFx, onReady, timeOutMillis=3000) ->
    start = new Date().getTime()
    condition = false
    f = ->
        if (new Date().getTime() - start < timeOutMillis) and not condition
            # If not time-out yet and condition not yet fulfilled
            condition = (if typeof testFx is 'string' then eval testFx else testFx()) #< defensive code
        else
            if not condition
                # If condition still not fulfilled (timeout but condition is 'false')
                #console.log "'waitFor()' timeout"
                phantom.exit(1)
            else
                # Condition fulfilled (timeout and/or condition is 'true')
                #console.log "'waitFor()' finished in #{new Date().getTime() - start}ms."
                if typeof onReady is 'string' then eval onReady else onReady() #< Do what it's supposed to do once the condition is fulfilled
                clearInterval interval #< Stop this interval
    interval = setInterval f, 100 #< repeat check every 100ms

if phantom.args.length isnt 1
    console.log 'Usage: run-jasmine.coffee URL'
    phantom.exit()

page = new WebPage()

# Route "console.log()" calls from within the Page context to the main Phantom context (i.e. current "this")
page.onConsoleMessage = (msg) ->
    console.log msg

page.open phantom.args[0], (status) ->
    if status isnt 'success'
        console.log 'Unable to access network'
        phantom.exit()
    else
        waitFor ->
            page.evaluate ->
                if document.body.querySelector '.finished-at'
                    return true
                return false
        , ->
            page.evaluate ->
                console.log document.body.querySelector('.description').innerText
                list = document.body.querySelectorAll 'div.jasmine_reporter > div.suite.failed'
                for i in list
                    el = i
                    desc = el.querySelectorAll '.description'
                    console.log ''
                    for j in desc
                        console.log j.innerText

            phantom.exit()
