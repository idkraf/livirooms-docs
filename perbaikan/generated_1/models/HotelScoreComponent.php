<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HotelScoreComponent extends Model
{
    protected $table = 'hotel_score_components';

    protected $fillable = [
        'hotel_id',
        'component',
        'score',
    ];

    public function hotel(): BelongsTo
    {
        return $this->belongsTo(Hotel::class);
    }
}
