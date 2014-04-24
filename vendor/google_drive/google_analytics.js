function clearSources() {
  var spreadsheet = SpreadsheetApp.openById("0Ah0x2WqLHvKCdHFkaEhDSFdtUl84MFJxMkZXUWxaQVE");
  var sheet = spreadsheet.getSheetByName('SMANIA search - source');
  sheet.clear();
  var sheet = spreadsheet.getSheetByName('SMANIA ad - source');
  sheet.clear();
}

function getData(url, sheet_name, active_cell_row, active_cell_column) {
  var results = fetchDataFromUrl(url);
  Logger.log(results);
  return outputToSpreadsheet(results, sheet_name, active_cell_row, active_cell_column);
}

function fetchDataFromUrl(url) {
  if(url == undefined) {
    var url = 'https://www.googleapis.com/analytics/v3/data/ga?ids=ga%3A72057961&dimensions=ga%3Acampaign&metrics=ga%3Atransactions%2Cga%3AitemQuantity&start-date=2014-04-01&end-date=2014-04-23&max-results=50';
  }
  var query = url.split('?')[1]
  var params = query?JSON.parse('{"' + query.replace(/&/g, '","').replace(/=/g,'":"') + '"}', 
               function(key, value) { return key===""?value:decodeURIComponent(value) }):{};
  return getReportData(params);
}

function getReportData(params) {

  var tableId = params['ids'];
  var startDate = params['start-date'];
  var endDate = params['end-date'];

  var optArgs = {
    'dimensions': params['dimensions'],
    'sort': params['sort'],
    'segment': params['segment'],
    'filters': params['filters'],
    'start-index': params['start-index'],
    'max-results': params['max-results']
  };

  // Make a request to the API.
  var results = Analytics.Data.Ga.get(
      tableId,                  // Table id (format ga:xxxxxx).
      startDate,                // Start-date (format yyyy-MM-dd).
      endDate,                  // End-date (format yyyy-MM-dd).
      params['metrics'], // Comma seperated list of metrics.
      optArgs);
  
  Logger.log(results);
  return results;
}

function getLastNdays(nDaysAgo) {
  var today = new Date();
  var before = new Date();
  before.setDate(today.getDate() - nDaysAgo);
  return Utilities.formatDate(before, 'GMT+1', 'yyyy-MM-dd');
}

function outputToSpreadsheet(results, sheet_name, active_cell_row, active_cell_column) {
  var spreadsheet = SpreadsheetApp.openById("0Ah0x2WqLHvKCdHFkaEhDSFdtUl84MFJxMkZXUWxaQVE");
  
  if (sheet_name == undefined) {
    var sheet = spreadsheet.getActiveSheet();
  } else {
    var sheet = spreadsheet.getSheetByName(sheet_name);
  }
  
  if(active_cell_column == undefined && active_cell_row == undefined) {
    var active_cell = sheet.getActiveCell();
    var active_cell_column = active_cell.getColumn();
    var active_cell_row = active_cell.getRow();
  }
  
  var active_cell_column = parseInt(active_cell_column);
  var active_cell_row = parseInt(active_cell_row);
  
  if(results.getRows() != undefined) {
    
    // Print the headers.
    var headerNames = ['ga:date'];
    for (var i = 0, header; header = results.getColumnHeaders()[i]; ++i) {
      headerNames.push(header.getName());
    }
    
    if(sheet.getLastRow() == 0) {
      sheet.getRange(1, 1, 1, headerNames.length).setValues([headerNames]);
    }
    
    // dodaj datum v prvi stolpec
    for (var i = 0; i < results.getRows().length; i++) {
      results.getRows()[i].unshift(results.query['start-date']);
    }
    
    sheet.getRange(sheet.getLastRow()+1, 1, results.getRows().length, headerNames.length).setValues(results.getRows());
    
  }
}

function enterGADate() {
  var response = Browser.inputBox('Enter Date (required format: 2014-02-12)', '', Browser.Buttons.OK_CANCEL);
  
  if (response == 'cancel') {
    return;
  } else {
   get_data(response);
  }
}

function onOpen() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var menuEntries = [];
  menuEntries.push({name: "Import GA data for specific date", functionName: "enterGADate"});

  ss.addMenu("Google Analytics", menuEntries);
}

// ad - http://ga-dev-tools.appspot.com/explorer/?dimensions=ga%253Asource%252Cga%253Acampaign%252Cga%253Amedium%252Cga%253AadContent&metrics=ga%253AitemQuantity%252Cga%253AadCost%252Cga%253AadClicks%252Cga%253AtransactionRevenue%252Cga%253Atransactions&filters=ga%253Akeyword%253D%253D(not%2520set)%253Bga%253AadCost!%253D0%252Cga%253Atransactions!%253D0&start-date=2013-12-16&end-date=2013-12-16&max-results=1000
// search - http://ga-dev-tools.appspot.com/explorer/?dimensions=ga%253Asource%252Cga%253Acampaign%252Cga%253Amedium%252Cga%253AadContent%252Cga%253Akeyword&metrics=ga%253AitemQuantity%252Cga%253AadCost%252Cga%253AadClicks%252Cga%253AtransactionRevenue%252Cga%253Atransactions&filters=ga%253Akeyword!%253D(not%2520set)%253Bga%253AadCost!%253D0%252Cga%253Atransactions!%253D0&start-date=2013-12-16&end-date=2013-12-16&max-results=1000

function get_data(current_date) {
  urls = {
  smania: {
    search: 'https://www.googleapis.com/analytics/v3/data/ga?ids=ga%3A72057961&dimensions=ga%3Asource%2Cga%3Acampaign%2Cga%3Amedium%2Cga%3AadContent%2Cga%3Akeyword&metrics=ga%3AitemQuantity%2Cga%3AadCost%2Cga%3AadClicks%2Cga%3AtransactionRevenue%2Cga%3Atransactions&filters=ga%3Akeyword!%3D(not%20set)%3Bga%3AadCost!%3D0%2Cga%3Atransactions!%3D0&sort=-ga%3Atransactions&start-date='+current_date+'&end-date='+current_date+'&max-results=10000',
    ad: 'https://www.googleapis.com/analytics/v3/data/ga?ids=ga%3A72057961&dimensions=ga%3Asource%2Cga%3Acampaign%2Cga%3Amedium%2Cga%3AadContent&metrics=ga%3AitemQuantity%2Cga%3AadCost%2Cga%3AadClicks%2Cga%3AtransactionRevenue%2Cga%3Atransactions&filters=ga%3Akeyword%3D%3D(not%20set)%3Bga%3AadCost!%3D0%2Cga%3Atransactions!%3D0&sort=-ga%3Atransactions&start-date='+current_date+'&end-date='+current_date+'&max-results=10000'
  }
  } 
  
  get_yesterdays_data_for_smania_search(urls);
  get_yesterdays_data_for_smania_ad(urls);
}

function test() {
  get_data('2014-04-23');
}

function get_yesterdays_data_for(url, account, type) {
  getData(url, account + ' ' + type + ' - source');
  
  var spreadsheet = SpreadsheetApp.openById("0Ah0x2WqLHvKCdHFkaEhDSFdtUl84MFJxMkZXUWxaQVE");
  var source_sheet = spreadsheet.getSheetByName(account + ' ' + type + ' - source');
  
  source_sheet.sort(1, false);
}

function get_yesterdays_data_for_smania_search(urls) {
  get_yesterdays_data_for(urls.smania.search, 'SMANIA', 'search');
}

function get_yesterdays_data_for_smania_ad(urls) {
  get_yesterdays_data_for(urls.smania.ad, 'SMANIA', 'ad');
}

function create_ss_for_adv() {
  var spreadsheet_emazing_analytics = SpreadsheetApp.openById("0Ah0x2WqLHvKCdHFkaEhDSFdtUl84MFJxMkZXUWxaQVE");
  var spreadsheet_emazing_analytics_id = spreadsheet_emazing_analytics.getId();
  var spreadsheet_emazing_analytics_file = DocsList.getFileById(spreadsheet_emazing_analytics_id);
  // var spreadsheet_for_adv_name = "Emazing Analytics - for Advertisers";
  //
  var folder_emazing = DocsList.getFolder('Emazing');
  var folder_root = DocsList.getFolder('/');
  
  var spreadsheet_for_adv_name = "Emazing Analytics - for Advertisers";
  var spreadsheet_for_adv = SpreadsheetApp.create(spreadsheet_for_adv_name);
  var spreadsheet_for_adv_id = spreadsheet_for_adv.getId();
  var file_for_adv = DocsList.getFileById(spreadsheet_for_adv_id);
  
  file_for_adv.addToFolder(folder_emazing);
  file_for_adv.removeFromFolder(folder_root);
 
  var sheet_smania_source_with_keywords = spreadsheet_emazing_analytics.getSheetByName('SMANIA search - source');
  var sheet_smania_source_without_keywords = spreadsheet_emazing_analytics.getSheetByName('SMANIA ad - source');
  var sheet_smania_with_keywords = spreadsheet_emazing_analytics.getSheetByName('SMANIA search');
  var sheet_smania_without_keywords = spreadsheet_emazing_analytics.getSheetByName('SMANIA ad');

  sheet_smania_source_with_keywords.copyTo(spreadsheet_for_adv).setName('SMANIA search - source').hideSheet();
  sheet_smania_source_without_keywords.copyTo(spreadsheet_for_adv).setName('SMANIA ad - source').hideSheet();
  sheet_smania_with_keywords.copyTo(spreadsheet_for_adv).setName('SMANIA search');
  sheet_smania_without_keywords.copyTo(spreadsheet_for_adv).setName('SMANIA ad');
  
  var sheet_data_from_crm = spreadsheet_emazing_analytics.getSheetByName('Date Picker');
  sheet_data_from_crm.copyTo(spreadsheet_for_adv).setName('Date Picker');
  
  var sheet_data_from_crm = spreadsheet_emazing_analytics.getSheetByName('Summary');
  sheet_data_from_crm.copyTo(spreadsheet_for_adv).setName('Summary');
  
  spreadsheet_for_adv.getSheetByName('Sheet1').hideSheet();
}

function notifyAboutUpdate() {
  var spreadsheet = SpreadsheetApp.openById("0Ah0x2WqLHvKCdHFkaEhDSFdtUl84MFJxMkZXUWxaQVE");
  var spreadsheet_id = spreadsheet.getId();
  var spreadsheet_file = DocsList.getFileById(spreadsheet_id);
  
  MailApp.sendEmail("zan.bagaric@gmail.com", 'Emazing Analytics - bsmart, na voljo so novi podatki', spreadsheet_file.getUrl());
  MailApp.sendEmail("tomaz.zlender@gmail.com", 'Emazing Analytics - bsmart, na voljo so novi podatki', spreadsheet_file.getUrl());
}

function update() {
  //get_yesterdays_data()
  //notifyAboutUpdate()
}

function delete_rows_in_source_by_date(date) {
  var spreadsheet_emazing_analytics = SpreadsheetApp.openById("0Ah0x2WqLHvKCdHFkaEhDSFdtUl84MFJxMkZXUWxaQVE");
  var sheet_smania_ad_source = spreadsheet_emazing_analytics.getSheetByName('SMANIA ad - source');
  var values = sheet_smania_ad_source.getRange('A2:A').getValues();
  for (var row in values) {
    //if (values[row] == true) {
    if (true) {
//      sheet_smania_ad_source.deleteRow(row);
      Logger.log(values[row]);
      Logger.log(Date(2014, 1, 10, 0, 0, 0, 0));
      Logger.log(Date.parse(values[row]));
    }
  }
}
