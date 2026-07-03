import '../../automation/services/local_web_automation.dart';
import '../models/scrape_request.dart';
import '../models/scrape_result.dart';

class ScraperApi {
  const ScraperApi({LocalWebAutomation? automation})
    : _automation = automation ?? const LocalWebAutomation();

  final LocalWebAutomation _automation;

  Future<ScrapeResult> runScrape({required ScrapeRequest request}) async {
    final result = await _automation.scrape(request.toJson());
    return ScrapeResult.fromJson(result.rawJson);
  }
}
