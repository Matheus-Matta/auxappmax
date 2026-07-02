import '../models/scrape_request.dart';
import '../models/scrape_result.dart';
import '../services/scraper_api.dart';

abstract class ScraperView {
  void setLoading(bool value);
  void showScrapeStarted();
  void showScrapeResult(ScrapeResult result);
  void showScrapeError(Object error);
}

class ScraperPresenter {
  ScraperPresenter({required ScraperApi api}) : _api = api;

  final ScraperApi _api;
  ScraperView? _view;

  void attach(ScraperView view) {
    _view = view;
  }

  void detach() {
    _view = null;
  }

  Future<void> runScrape({
    required String backendBaseUrl,
    required String token,
    required ScrapeRequest request,
  }) async {
    _view
      ?..setLoading(true)
      ..showScrapeStarted();

    try {
      final result = await _api.runScrape(
        backendBaseUrl: backendBaseUrl,
        token: token,
        request: request,
      );
      _view?.showScrapeResult(result);
    } catch (error) {
      _view?.showScrapeError(error);
    } finally {
      _view?.setLoading(false);
    }
  }
}
