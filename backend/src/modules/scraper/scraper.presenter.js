export function presentScrapeResult(result) {
  if (!result.ok) {
    return {
      status: 500,
      body: {
        ok: false,
        error: result.error,
        scrapeRun: result.scrapeRun,
      },
    };
  }

  return {
    status: 200,
    body: {
      ok: true,
      title: result.title,
      finalUrl: result.finalUrl,
      text: result.text,
      scrapeRun: result.scrapeRun,
    },
  };
}

export function presentValidationFailure(error) {
  return {
    ok: false,
    error: 'Payload invalido.',
    details: error.flatten(),
  };
}
