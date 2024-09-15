package com.example.mybookapp

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.widget.EditText
import android.widget.Button
import android.widget.ListView
import okhttp3.*
import com.google.gson.Gson
import com.google.gson.JsonObject
import java.io.IOException

class MainActivity : AppCompatActivity() {
    private lateinit var searchField: EditText
    private lateinit var searchButton: Button
    private lateinit var listView: ListView
    private val client = OkHttpClient()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        searchField = findViewById(R.id.search_field)
        searchButton = findViewById(R.id.search_button)
        listView = findViewById(R.id.book_list)

        searchButton.setOnClickListener {
            val query = searchField.text.toString()
            searchBooks(query)
        }
    }

    private fun searchBooks(query: String) {
        val url = "https://www.googleapis.com/books/v1/volumes?q=$query"
        val request = Request.Builder().url(url).build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                e.printStackTrace()
            }

            override fun onResponse(call: Call, response: Response) {
                response.body?.let { body ->
                    val jsonResponse = Gson().fromJson(body.string(), JsonObject::class.java)
                    val items = jsonResponse.getAsJsonArray("items")

                    runOnUiThread {
                        val books = items.map { item ->
                            val volumeInfo = item.asJsonObject.getAsJsonObject("volumeInfo")
                            val title = volumeInfo.get("title").asString
                            val authors = volumeInfo.getAsJsonArray("authors").joinToString(", ") { it.asString }
                            val publishedDate = volumeInfo.get("publishedDate").asString
                            "$title - $authors ($publishedDate)"
                        }

                        listView.adapter = ArrayAdapter(this@MainActivity, android.R.layout.simple_list_item_1, books)
                    }
                }
            }
        })
    }
}
