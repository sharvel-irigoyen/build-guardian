<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model;

class File extends Model
{
    use HasFactory;

    protected $connection = 'mongodb';

    // equivalent to $table for MySQL
    protected $collection = 'user_files';

    protected $fillable = [
        'user_id', 'name', 'type', 'data',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
