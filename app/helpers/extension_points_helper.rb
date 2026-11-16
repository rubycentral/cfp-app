# Generic view hooks. Core views call `render_extensions(:point)`; optional
# engines register partial paths under `config.x.extension_points[:point]`.
module ExtensionPointsHelper
  def render_extensions(point, **locals)
    safe_join(Rails.application.config.x.extension_points[point].map { |partial| render(partial:, locals:) })
  end
end
