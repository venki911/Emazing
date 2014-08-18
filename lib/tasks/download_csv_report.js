// run with `casperjs --web-security=no fb_daily_report.js`
// commented are line intended for debugging

var casper = require('casper').create({
    verbose: true,
    logLevel: "debug"
});

casper.start();

casper.thenOpen('https://www.facebook.com/ads/manage/reporting.php?act='+casper.cli.get('facebook-ads-account-id'), function() {
	this.fill('form#login_form', {
		'email': casper.cli.get('facebook-username'),
		'pass': casper.cli.get('facebook-password')
	}, true);
	this.echo("Logging...");
});

casper.wait(10000, function() {
  // this.capture('1_logged_in.png');
	this.echo("Logged in.");
});

casper.waitFor(function check() {
  return this.evaluate(function() {
    return document.querySelectorAll('.bt-report-selector').length > 0;
  });
}, function then() {
		this.wait(10000, function() {
		  // this.capture('2_ads_loaded.png');
			this.echo("Ads Reports loaded.");
		});
}, function timeout() {
		// this.capture('2_ads_loaded_failed.png');
    this.echo("Reports link not found.").exit();
}, 15000);

casper.then(function() {
	this.click('.bt-report-selector a[role=button]');
});

casper.waitFor(function check() {
  return this.evaluate(function() {
    return document.querySelectorAll('.bt-selector-item').length > 0;
  });
}, function then() {
		this.wait(3000, function() {
		  // this.capture('3_reports_list_opened.png');
			this.echo("Reports List opened.");
		});
}, function timeout() {
		// this.capture('3_reports_list_opened_failed.png');
    this.echo("Reports List didn't opened.").exit();
}, 15000);

casper.then(function() {
	report_link = this.evaluate(function() {
		var reports_links = document.querySelectorAll('.bt-selector-item');
		var chosen_report_link = Array.prototype.filter.call(reports_links, function(report_link) {
			return report_link.textContent.indexOf("ID01") > -1;
		});
		var report_link = chosen_report_link[0];
		report_link.className = report_link.className + ' temporary_class_for_marking_link_for_click';
		return report_link;
	});
	this.echo(report_link.className);
	this.click('.temporary_class_for_marking_link_for_click');
	this.echo('CLICKED LINK: ' + report_link.textContent);
});

// izpopolni, tako da preveri ali se je porocilo nalozilo
casper.wait(5000, function() {
  // this.capture('4_opened_daily_custom_data_report.png');
	this.echo("Daily Custom Data Report for GA opened.");
});

casper.then(function() {
	this.click('.bt-export-button');
	this.echo('Link Export clicked.');
});

casper.wait(3000, function() {
  // this.capture('5_export_popup_opened.png');
	this.echo("Popup Export opened.");
});

casper.then(function() {
	this.click('.bt-menu-item:last-child');
	this.echo('Link Export Report (.csv) clicked.');
});

casper.waitForResource(function testResource(resource) {
    return resource.url.indexOf('https://graph.facebook.com/act_'+casper.cli.get('facebook-ads-account-id')+'/reportstats?') === 0;
}, function onReceived(resource) {
    this.echo('CSV received.');
});

casper.on('navigation.requested', function(url) {
	if (url.indexOf('https://graph.facebook.com/act_'+casper.cli.get('facebook-ads-account-id')+'/reportstats?') == 0) {
		this.download(url, casper.cli.get('temp-csv-path'));
		this.echo('CSV downloaded: ' + casper.cli.get('temp-csv-path'));
	};
});

casper.run();