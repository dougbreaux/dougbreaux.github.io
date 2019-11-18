---
title: Spring Web Flow progress logging
tags: [ webflow, spring, logging]
---
Small technique we use for getting useful "step" logging from [Spring Web Flow](https://projects.spring.io/spring-webflow/) applications, where the URL itself doesn't tell you what path a user is taking through your application. Which is often useful for investigating issues.

The basic entity of this solution is a custom <span style="font-family:courier new,courier,monospace;">[FlowExecutionListener](https://docs.spring.io/spring-webflow/docs/current/api/org/springframework/webflow/execution/FlowExecutionListener.html)</span>, with the `stateEntered()` method implemented to log information about the current state and transition. We include the HTTP Session ID so that we can track a single user's path through the flow.
```java
    @Override  
    public void stateEntered(RequestContext context, StateDefinition previousState, StateDefinition newState)  {  
        logProgress(context);  
    }

    private static Logger progress = Logger.getLogger("progress");

    /**  
     * Method for logging some standard progress indicators, callable from any SWF state.  
     * Currently uses a separate log4j Logger ({@link #progress}), and logs timestamp, Session ID,  
     * User-Agent header, SWF execution key (eXsY), SWF state name, and SWF event name.  
     * <p>Note the execution key is for the POST portion of the POST-Redirect-GET flow. Thus, it  
     * will match what appeared in the user's browser before the current view, not what appears  
     * when looking at the rendered view.</p>  
     */  
    public static void logProgress(RequestContext context) {  
        HttpServletRequest req = (HttpServletRequest) (context.getExternalContext().getNativeRequest());

        StringBuilder sb = new StringBuilder();  
        sb.append(req.getSession().getId()).append(", ")  
          .append(req.getHeader("User-Agent")).append(", ")  
          .append(context.getFlowExecutionContext().getKey()).append(", ")  
          .append(context.getCurrentState().getId());

        Event event = context.getCurrentEvent();  
        if (event != null) {  
            sb.append(", ").append(event.getId());  
        }

        progress.info(sb.toString());  
    }
```
You configure a FlowExecutionListener for Spring Web Flow like this:
```xml
<bean id="progressLoggingListener" class="my.custom.webflow.ProgressLoggingFlowExecutionListener"/>

    <webflow:flow-executor id="flowExecutor">  
        <webflow:flow-execution-listeners>  
            <webflow:listener ref="progressLoggingListener"/>  
        </webflow:flow-execution-listeners>  
    </webflow:flow-executor>
```
