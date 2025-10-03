"""Interactive article tagging workflow."""

from ..api import api
from ..config import config
from ..ui import ui


def run_tagging_wizard(article_id: str | None = None):
    """Run interactive tagging wizard for an article."""

    # Load tag mapping
    config.load_tag_mapping()

    # Get article
    if not article_id:
        # List recent articles and let user choose
        ui.header("Article Tagging", "🏷️")
        ui.info("Loading your recent articles...\n")

        try:
            response = api.list_documents()
            articles = response.get("results", [])[:20]  # Last 20 articles

            if not articles:
                ui.error("No articles found.")
                return

            article_options = [
                f"{a.get('title', 'Untitled')} ({len(a.get('tags', []))} tags)" for a in articles
            ]

            selected = ui.filter_list(
                article_options,
                placeholder="Search articles...",
                prompt="? Select article to tag: ",
            )

            if not selected:
                ui.info("No article selected.")
                return

            # Find selected article
            selected_index = article_options.index(selected)
            article = articles[selected_index]
            article_id = article["id"]

        except Exception as e:
            ui.error(f"Error loading articles: {e}")
            return
    else:
        try:
            article = api.get_document(article_id)
        except Exception as e:
            ui.error(f"Error loading article: {e}")
            return

    # Display article info
    title = article.get("title", "Untitled")
    url = article.get("url", "")
    current_tags = article.get("tags", [])

    ui.style(f"\n📄 {title}", foreground="212", bold=True)
    if url:
        ui.info(f"   {url}")
    if current_tags:
        ui.info(f"   Current tags: {', '.join(current_tags)}\n")
    else:
        ui.info("   (no tags yet)\n")

    # Step 1: Select PARA category
    ui.style("Step 1: PARA Category", foreground="147", bold=True)
    para_categories = config.get_para_categories()

    para_options = []
    for _category_type, items in para_categories.items():
        for item in items:
            para_options.append(f"{item['code']} - {item['name']}")

    selected_para = ui.choose(para_options, prompt="? Select PARA category: ")

    if not selected_para:
        ui.info("Tagging cancelled.")
        return

    para_code = selected_para.split(" - ")[0]

    # Step 2: Choose domain
    ui.style("\nStep 2: Domain", foreground="147", bold=True)
    domains = config.get_domains()

    domain_options = [f"{code} - {name}" for code, name in domains.items()]

    selected_domain = ui.choose(domain_options, prompt="? Choose domain: ")

    if not selected_domain:
        ui.info("Tagging cancelled.")
        return

    domain_code = selected_domain.split(" - ")[0]

    # Step 3: TFP connections
    ui.style("\nStep 3: TFP Connections", foreground="147", bold=True)
    tfps = config.get_tfps()

    tfp_options = [f"{code} - {question}" for code, question in tfps.items()]

    selected_tfps = ui.choose(
        tfp_options,
        prompt="? Select TFP connections (space to select, enter to confirm): ",
        multiple=True,
    )

    tfp_tags = []
    if selected_tfps:
        tfp_tags = [option.split(" - ")[0] for option in selected_tfps]

    # Step 4: Processing layer
    ui.style("\nStep 4: Processing Layer", foreground="147", bold=True)
    layers = config.get_layers()

    layer_options = [f"{code} - {desc}" for code, desc in layers.items()]

    selected_layer = ui.choose(layer_options, prompt="? Processing layer: ")

    layer_tag = selected_layer.split(" - ")[0] if selected_layer else "layer1"

    # Step 5: Action level
    ui.style("\nStep 5: Action Level", foreground="147", bold=True)
    action_levels = config.get_action_levels()

    action_options = [f"{code} - {desc}" for code, desc in action_levels.items()]

    selected_action = ui.choose(action_options, prompt="? Action level: ")

    action_tag = selected_action.split(" - ")[0] if selected_action else "ref"

    # Build final tag set
    basb_tag = f"{para_code.lower()}-{domain_code.lower()}"
    new_tags = [basb_tag] + tfp_tags + [layer_tag, f"actionable-{action_tag}"]

    # Keep existing tags that aren't being replaced
    final_tags = []
    for tag in current_tags:
        # Remove old BASB tags, layer tags, and action tags
        if not (
            tag.startswith(("p1-", "p2-", "p3-", "a1-", "a2-", "a3-", "r2-", "r3-", "x2-", "x3-"))
            or tag.startswith("layer")
            or tag.startswith("actionable-")
            or tag.startswith("tfp")
        ):
            final_tags.append(tag)

    final_tags.extend(new_tags)

    # Display summary
    ui.style("\n" + "─" * 60, foreground="212")
    ui.style("TAGS TO APPLY", foreground="212", bold=True)
    ui.style("─" * 60, foreground="212")

    for tag in final_tags:
        ui.style(f"  #{tag}", foreground="147")

    ui.style("─" * 60, foreground="212")

    # Confirm and apply
    if ui.confirm("\n? Apply these tags to Readwise?", default=True):
        try:
            api.update_document(article_id, tags=final_tags)
            ui.success("\n✓ Tags applied successfully!")

            # Check if ready for export
            if layer_tag in ["layer3-highlighted", "layer4-summary"]:
                ui.info("✓ Article queued for Drive export")

            # Check if actionable
            if action_tag == "now":
                ui.info("💡 Article marked for immediate action - add to Sunsama!")

        except Exception as e:
            ui.error(f"\n✗ Failed to apply tags: {e}")
    else:
        ui.info("Tags not applied.")


if __name__ == "__main__":
    import sys

    article_id = sys.argv[1] if len(sys.argv) > 1 else None
    run_tagging_wizard(article_id)
