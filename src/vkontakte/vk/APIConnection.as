package vkontakte.vk {
  import flash.net.LocalConnection;
  import flash.external.ExternalInterface;
  import flash.events.*;
  import flash.utils.setTimeout;

  import vkontakte.vk.api.CustomEvent;
  import vkontakte.vk.api.DataProvider;
//  //import com.junkbyte.console.Cc;


  /**
   * @author Andrew Rogozov
   */
  public class APIConnection extends EventDispatcher {
    private var sendingLC: LocalConnection;
    private var connectionName: String;
    private var receivingLC: LocalConnection;
    
    private var pendingRequests: Array;
    private var loaded: Boolean = false;
	
	private var dp: DataProvider;
    
    public function APIConnection(...params) {
	  var connectionName: String;
	  if (typeof(params[0]) == 'string') {
	    connectionName = params[0];
	  } else {
	    connectionName = params[0].lc_name;
		var api_url: String = 'http://api.vkontakte.ru/api.php';
		if (params[0].api_url) api_url = params[0].api_url;
		dp = new DataProvider(api_url, params[0].api_id, params[0].sid, params[0].secret, params[0].viewer_id);
	  }
	  if (!connectionName) return;
	  pendingRequests = new Array();
      
      this.connectionName = connectionName;
      
      sendingLC = new LocalConnection();
      sendingLC.allowDomain('*');
      
      receivingLC = new LocalConnection();
      receivingLC.allowDomain('*');
      receivingLC.client = {
        initConnection: initConnection,
        onBalanceChanged: onBalanceChanged,
        onSettingsChanged: onSettingsChanged,
		onLocationChanged: onLocationChanged,
		onWindowResized: onWindowResized,
		onApplicationAdded: onApplicationAdded,
		onWindowBlur: onWindowBlur,
		onWindowFocus: onWindowFocus,
		onWallPostSave: onWallPostSave,
		onWallPostCancel: onWallPostCancel,
		onProfilePhotoSave: onProfilePhotoSave,
		onProfilePhotoCancel: onProfilePhotoCancel,
		onMerchantPaymentSuccess: onMerchantPaymentSuccess,
		onMerchantPaymentCancel: onMerchantPaymentCancel,
		onMerchantPaymentFail: onMerchantPaymentFail,
		customEvent: customEvent
      };
      try {
        receivingLC.connect("_out_" + connectionName);
      } catch (error:ArgumentError) {
        debug("Can't connect from App. The connection name is already being used by another SWF");
      }
      sendingLC.addEventListener(StatusEvent.STATUS, onInitStatus);
      sendingLC.send("_in_" + connectionName, "initConnection");
    }
    
    /*
     * Public methods
     */
	public function callMethod(...params):void {
	  var paramsArr: Array = params as Array;
	  paramsArr.unshift("callMethod");
	  sendData.apply(this, paramsArr);
	}
	
    public function debug(msg: *): void {
      if (!msg || !msg.toString) {
        return;
      }
      sendData("debug", msg.toString());
    }
	
	public function api(method: String, params: Object, onComplete:Function = null, onError:Function = null):void {
	  var options: Object = new Object();
	  options['params'] = params;
	  options['onComplete'] = onComplete;
	  options['onError'] = onError;
	  dp.request(method, options);
	}
  
    /*
     * Callbacks
     */
    private function initConnection(): void {
      if (loaded) return;
      loaded = true;
      debug("Connection initialized.");
      dispatchEvent(new CustomEvent(CustomEvent.CONN_INIT));
      sendPendingRequests();
    }

	public function customEvent(...params): void {
	  var paramsArr: Array = params as Array;
	  var eventName: String = paramsArr.shift();
	  debug(eventName);
	  var e:CustomEvent = new CustomEvent(eventName);
	  e.params = paramsArr;
	  dispatchEvent(e);
	}
	
	/*
     * Obsolete callbacks
     */
	private function onBalanceChanged(...params): void {
	  var paramsArr: Array = params as Array;
	  paramsArr.unshift('onBalanceChanged')
	  customEvent.apply(this, paramsArr);
	}
	
	private function onSettingsChanged(...params): void {
	  var paramsArr: Array = params as Array;
	  paramsArr.unshift('onSettingsChanged')
	  customEvent.apply(this, paramsArr);
	}
	
	private function onLocationChanged(...params): void {
	  var paramsArr: Array = params as Array;
	  paramsArr.unshift('onLocationChanged')
	  customEvent.apply(this, paramsArr);
	}
	
	private function onWindowResized(...params): void {
	  var paramsArr: Array = params as Array;
	  paramsArr.unshift('onWindowResized')
	  customEvent.apply(this, paramsArr);
	}
	
	private function onApplicationAdded(...params): void {
	  var paramsArr: Array = params as Array;
	  paramsArr.unshift('onApplicationAdded')
	  customEvent.apply(this, paramsArr);
	}
	
	private function onWindowBlur(...params): void {
	  var paramsArr: Array = params as Array;
	  paramsArr.unshift('onWindowBlur')
	  customEvent.apply(this, paramsArr);
	}
	
	private function onWindowFocus(...params): void {
	  var paramsArr: Array = params as Array;
	  paramsArr.unshift('onWindowFocus')
	  customEvent.apply(this, paramsArr);
	}
	
	private function onWallPostSave(...params): void {
	  var paramsArr: Array = params as Array;
	  paramsArr.unshift('onWallPostSave')
	  customEvent.apply(this, paramsArr);
	}
	
	private function onWallPostCancel(...params): void {
	  var paramsArr: Array = params as Array;
	  paramsArr.unshift('onWallPostCancel')
	  customEvent.apply(this, paramsArr);
	}
	
	private function onProfilePhotoSave(...params): void {
	  var paramsArr: Array = params as Array;
	  paramsArr.unshift('onProfilePhotoSave')
	  customEvent.apply(this, paramsArr);
	}
	
	private function onProfilePhotoCancel(...params): void {
	  var paramsArr: Array = params as Array;
	  paramsArr.unshift('onProfilePhotoCancel')
	  customEvent.apply(this, paramsArr);
	}
	
	private function onMerchantPaymentSuccess(...params): void {
	  var paramsArr: Array = params as Array;
	  paramsArr.unshift('onMerchantPaymentSuccess')
	  customEvent.apply(this, paramsArr);
	}
	
	private function onMerchantPaymentCancel(...params): void {
	  var paramsArr: Array = params as Array;
	  paramsArr.unshift('onMerchantPaymentCancel')
	  customEvent.apply(this, paramsArr);
	}
	
	private function onMerchantPaymentFail(...params): void {
	  var paramsArr: Array = params as Array;
	  paramsArr.unshift('onMerchantPaymentFail')
	  customEvent.apply(this, paramsArr);
	}
     
    /*
     * Private methods
     */
    private function sendPendingRequests(): void {
      while (pendingRequests.length) {
        sendData.apply(this, pendingRequests.shift());
      }
    }
    
    private function sendData(...params):void {
      var paramsArr: Array = params as Array;
      if (loaded) {
        paramsArr.unshift("_in_" + connectionName);
        sendingLC.send.apply(null, paramsArr);
      } else {
        pendingRequests.push(paramsArr);
      }
    }
    private function onInitStatus(e:StatusEvent):void {
      debug("StatusEvent: "+e.level);
      e.target.removeEventListener(e.type, onInitStatus);
      if (e.level == "status") {
        receivingLC.client.initConnection();
      }
    }
  }
}
