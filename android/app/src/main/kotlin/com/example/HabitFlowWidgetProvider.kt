class HabitFlowWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context,
                          manager: AppWidgetManager,
                          ids: IntArray) {
        ids.forEach { update(context, manager, it) }
    }

    private fun update(context: Context,
                       manager: AppWidgetManager,
                       id: Int) {
        val prefs  = context.getSharedPreferences(
            "FlutterSharedPreferences", Context.MODE_PRIVATE)
        val json   = prefs.getString("flutter.habitflow_data", null)
                     ?: return

        val data   = JSONObject(json)
        val streak = data.optInt("streak", 0)
        val done   = data.optInt("done", 0)
        val total  = data.optInt("total", 1)
        val mood   = data.optString("mood_emoji", "")
        val pct    = if (total > 0) (done * 100) / total else 0

        val views = RemoteViews(context.packageName, R.layout.habit_widget)
        views.setTextViewText(R.id.tv_streak, "🔥 $streak")
        views.setTextViewText(R.id.tv_mood, mood)
        views.setProgressBar(R.id.pb_progress, 100, pct, false)
        views.setTextViewText(R.id.tv_progress_label, "$done/$total habits done")

        // Tap → open app
        val intent = Intent(context, MainActivity::class.java).apply {
            data = Uri.parse("habitflow://home")
        }
        views.setOnClickPendingIntent(
            android.R.id.background,
            PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        )

        manager.updateAppWidget(id, views)
    }
}