//	PlainAjax engine 1.02a: http://coolpenguin.net/plainajax

function PlainAjax() {

	this.timeout = 300000;

	this.requests = new Array();
	this.reqnextid = 0;

	this.request = function(paramstring, resultfunc) {
		var request = new this.PlainAjaxRequest(this.nextReqId(), paramstring, resultfunc);
		if (request.conftext == null || confirm(request.conftext))
			this.newRequest(request);
	}

	this.nextReqId = function() {
		return ++this.reqnextid;
	}

	this.newRequest = function(request) {
		this.requests.push(request);
		request.doRequest();
	}

	this.getRequest = function(id) {
		return this.requests[this.getPos(id)];
	}

	this.delRequest = function(id) {
		this.requests.splice(this.getPos(id), 1);
	}

	this.getPos = function(id) {
		for ( var i = 0; i < this.requests.length; ++i)
			if (this.requests[i].id == id)
				return i;
		throw "No request: " + id;
	}

	this.PlainAjaxRequest = function(id, paramString, resultfunc) {

		this.id = id;
		this.resultfunc = resultfunc;
		this.timestamp = new Date().getTime();
		this.xmlhttp;

		this.respurl;
		this.resultloc;
		this.paramloc;
		this.autoresend;
		this.conftext;
		this.loadmsg;
		this.loadmsgloc;

		this.trimText = function(text) {
			while (text.substring(0, 1) == ' ')
				text = text.substring(1, text.length);
			while (text.substring(text.length - 1, text.length) == ' ')
				text = text.substring(0, text.length - 1);
			return text;
		}

		this.def = function(x) {
			return (x != undefined && x != null);
		}

		this.processParamString = function(paramString) {
			var pars = paramString.split(';');
			for ( var pari = 0; pari < pars.length; ++pari) {
				var parStr = pars[pari];
				var par = parStr.split(':');
				if (par.length == 2) {
					var name = this.trimText(par[0]);
					var value = this.trimText(par[1]);
					this.processParam(name, value);
				}
			}
		}

		this.processParam = function(name, value) {
			switch (name) {
				case "respurl": this.respurl = value; break;
				case "resultloc": this.resultloc = value; break;
				case "paramloc": this.paramloc = value; break;
				case "autoresend": this.autoresend = value; break;
				case "conftext": this.conftext = value; break;
				case "loadmsg": this.loadmsg = value; break;
			}
		}

		this.processParamString(paramString);

		this.resultReceiver = function() {
			var reqId = this.id;
			var rr = function() {
				var request = window.plainajax.getRequest(reqId);
				request.receiveResult();
			}
			return rr;
		}

		this.receiveResult = function() {
			if (this.xmlhttp.readyState == 4 && this.xmlhttp.status == 200) {
				var resp = this.xmlhttp.responseText;
				this.putToElem(this.resultloc, resp);
				if (this.def(this.resultfunc))
					this.resultfunc(resp);
				if (!this.def(this.autoresend))
					window.plainajax.delRequest(this.id);
			}
		}

		this.doRequest = function() {
			this.manualRequest();
			this.autoRequest();
		}

		this.manualRequest = function() {
			var qs = this.createQS();
			this.initXmlHttp(qs);
			this.loadMsg();
			this.timestamp = new Date().getTime();
			this.xmlhttp.send(qs);
		}

		this.autoRequest = function() {
			if (this.def(this.autoresend)) {
				var reqId = this.id;
				var ar = function() {
					var request = window.plainajax.getRequest(reqId);
					request.manualRequest();
				}
				setInterval(ar, this.autoresend);
			}

		}

		this.createUrl = function() {
			var connectchar = this.respurl.indexOf('?') != -1 ? '&' : '?';
			var url = this.respurl + connectchar + "timeStamp=" + this.timestamp;
			return url;
		}

		this.getFields = function() {
			var pdiv = document.getElementById(this.paramloc);
			var fieldtypes = new Array("input", "textarea", "select");
			fields = new Array();
			for (typei = 0; typei < fieldtypes.length; ++typei) {
				var fieldtype = fieldtypes[typei];
				var nodes = pdiv.getElementsByTagName(fieldtype);
				for (nodeid = 0; nodeid < nodes.length; ++nodeid) {
					var node = nodes[nodeid];
					if ((fieldtype != "input" || (fieldtype == "input" && node.type != "button" && node.type != "file")	&& ((node.type != "checkbox" && node.type != "radio") || (node.checked))) && ((fieldtype == "input" || fieldtype == "textarea" || fieldtype == "select") && !node.disabled))
						fields.push(node);
				}
			}
			return fields;
		}

		this.createQS = function() {
			var qs = '';
			if (this.paramloc != null) {
				var fields = this.getFields();
				var first = true;
				for (i = 0; i < fields.length; ++i) {
					var node = fields[i];
					if (node.name != "" && node.type != "file") {
						if (!first)
							qs += '&';
						else
							first = false;
						qs += node.name + '=' + escape(node.value);
					}
				}
			}
			return qs;
		}

		this.initXmlHttp = function(queryString) {
			this.xmlhttp = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject("MSXML2.XMLHTTP.3.0");
			var method = (this.paramloc == null) ? "GET" : "POST";
			this.xmlhttp.open(method, this.createUrl(), true);
			this.xmlhttp.onreadystatechange = this.resultReceiver();
			this.xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
			this.xmlhttp.setRequestHeader("Connection", "close");
			this.xmlhttp.setRequestHeader("Content-length",	queryString.length);
		}

		this.loadMsg = function() {
			if (this.loadmsg != null) {
				var target = this.loadmsgloc == null ? this.resultloc : this.loadmsgloc;
				this.putToElem(target, this.loadmsg);
			}
		}

		this.putToElem = function(id, v) {
			if(id) {
				var t = document.getElementById(id);
				if (t != null) {
					if (t.tagName == 'TEXTAREA')
						t.value = v;
					else
						t.innerHTML = v;
				}
			}
		}
	}
}

var plainajax = new PlainAjax();
window.plainajax = plainajax;

