<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('user_files', function (Blueprint $collection) {
            $collection->id();
            $collection->foreignId('user_id')->constrained('users');
            $collection->string('name');
            $collection->string('type'); // video, audio, etc.
            $collection->binary('data'); // for storing the file as binary
            $collection->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('files');
    }
};
